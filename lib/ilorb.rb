require "logger"
require "socket"
require "openssl"
require "net/https"
require "nokogiri"
require "nori"
require "ilorb/ribcl"

# Main library class
class ILORb
  def initialize(config = {})
    @hostname = config[:hostname]
    @login = config[:login] || "Administrator"
    @password = config[:password]
    @port = config[:port] || 443
    @protocol = config[:protocol] || :http
    @verify_ssl = config[:verify_ssl] || false
    @ribcl_path = "/ribcl"

    @log = Logger.new(STDOUT)
    @log.level = config[:debug] ? Logger::DEBUG : Logger::WARN

    @nori = Nori.new(convert_tags_to: ->(tag) { tag.downcase.to_sym })

    setup_commands
  end

  # args should be empty or contain a hash anytime
  def method_missing(name, *args, &block)
    if @ribcl.command?(name)
      command = @ribcl.command(name)

      fail RIBCL::NotImplementedError, "#{name} is not supported" unless command.supported?
      @log.info("Calling method #{name}")

      params = args.first || {}
      attributes = {}

      command.get_attributes.each do |attr|
        # Attributes are mandatory
        fail "Attribute #{attr} missing in #{name} call" unless params.key?(attr)
        attributes.store(attr, @ribcl.encode(params.delete(attr)))
      end

      if !command.get_elements.empty?
        element_map = command.map_elements

        elements_array = [params].flatten.map do |params_hash|
          Hash[params_hash.map { |k, _| [k, @ribcl.encode(params_hash.delete(k))] if element_map.key?(k) }.compact]
        end

        # TODO: check for CDATA

        request = ribcl_request(command, attributes) do |xml|
          elements_array.each do |elements_hash|
            elements_hash.each do |key, value|
              elt = command.get_elements[element_map[key].first]
              if elt.is_a?(Array)
                attrs = Hash[elt.map { |x| [x, elements_hash.delete(element_map.invert[[element_map[key].first, x]])] }]
              else
                attrs = { element_map[key].last => value }
              end
              xml.send(element_map[key].first, attrs)
            end
          end
        end
      elsif !command.get_text.nil?
        if (text = params[command.get_text])
          request = ribcl_request(command, text, attributes)
        end
      else
        request = ribcl_request(command, attributes)
      end

      response = send_request(request)
      parse_response(response)
    else
      super
    end
  end

  def respond_to(name)
    @ribcl.command?(name) ? true : super
  end

  def supported_commands
    @ribcl.select { |_, command| command.supported? }.keys
  end

  private

  def ribcl_request(command, *args)
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.ribcl(version: "2.0") do
        xml.login(password: @password, user_login: @login) do
          xml.send(command.context, mode: command.mode) do
            xml.send(command.name, *args) do
              yield xml if block_given?
            end
          end
        end
      end
    end

    builder.to_xml
  end

  def send_request(xml)
    case @protocol
    when :http
      send_http_request(xml)
    when :raw
      send_raw_request(xml)
    end
  end

  # ILO >= 3 speak HTTP
  # Send XML request with HTTP POST and get back XML messages
  def send_http_request(xml)
    http = Net::HTTP.new(@hostname, @port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE unless @verify_ssl

    @log.info("Sending POST request to #{@hostname}:#{@port}#{@ribcl_path}")
    @log.debug("Request:\n#{xml}")
    response = http.post(@ribcl_path, xml)
    if response.is_a?(Net::HTTPNotFound)
      @protocol = :raw
      @log.info("Got 404, switching to RAW protocol")
      send_raw_request(xml)
    else
      response.body
    end
  end

  # Older ILO just eat raw XML
  # Send XML over raw SSL-wrapped TCP socket and read XML stream
  def send_raw_request(xml)
    sock = TCPSocket.new(@hostname, @port)

    ctx = OpenSSL::SSL::SSLContext.new(:TLSv1)
    ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE unless @verify_ssl
    ssl_sock = OpenSSL::SSL::SSLSocket.new(sock, ctx)
    ssl_sock.sync_close = true

    @log.info("Connecting to #{@hostname}:#{@port}")
    @log.debug("Request:\n#{xml}")
    ssl_sock.connect
    ssl_sock.puts("#{xml}\r\n")
    response = ""
    while (line = ssl_sock.gets)
      response += line
    end
    ssl_sock.close

    response
  end

  def parse_response(xml)
    @log.debug("Response:\n#{xml}")

    # ILO sends back multiple XML documents, split by XML header and remove first (empty)
    messages = xml.split(/<\?xml.*?\?>\r?\n/).drop(1)

    output = {}

    messages.each do |doc|
      xml_doc = Nokogiri::XML(doc) { |cfg| cfg.nonet.noblanks }

      xml_doc.root.children.each do |node|
        case node.name
        when "RESPONSE"
          code = node.attr("STATUS").to_i(16)
          message = node.attr("MESSAGE")
          output[:status] = { code: code, message: message }
          if code != 0
            @log.error("#{message} (#{code})")
            break
          end
        when "INFORM"
          # OSEF
        else # actual result
          output.merge!(@nori.parse(node.to_s))
        end
      end
    end

    output
  end

  def setup_commands
    @ribcl = ILORb::RIBCL.load(File.join(File.dirname(__FILE__), "ilorb/definitions", "*.rb"))
    nil
  end
end
