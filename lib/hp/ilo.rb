require 'logger'
require 'socket'
require 'openssl'
require 'net/https'
require 'nokogiri'
require 'nori'

module HP
  class ILO
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

      @nori = Nori.new(:convert_tags_to => lambda{|tag| tag.downcase.to_sym})

      setup_commands
    end

    # args should be empty or contain a hash anytime
    def method_missing(name, *args, &block)
      if @ribcl.has_command?(name)
        params = args.first || {}
        attributes = {}
        elements = {}

        if @ribcl.has_attributes?(name)
          @ribcl.get_attributes(name).each do |attr|
            fu("Attribute #{attr} missing in #{name} call") unless params.has_key?(attr)
            attributes[attr] = params[attr]
          end
        end

        #TODO manage elements with attribute name != "value"
        if @ribcl.has_elements?(name)
          @ribcl.get_elements(name).each do |elt|
            fu("Element #{elt} missing in #{name} call") unless params.has_key?(elt)
            elements[elt] = params[elt]
          end
        end

        #TODO manage commands with elements
        @log.info("Calling method #{name}")
        request = ribcl_request(name, attributes)

        response = send_request(request)
        parse_response(response, name)
      else
        super
      end
    end

    def respond_to(name)
      @ribcl.has_command?(name) ? true : super
    end

    def known_commands
      @ribcl.keys
    end

    private

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
      ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
      ssl_sock = OpenSSL::SSL::SSLSocket.new(sock, ctx)
      ssl_sock.sync_close = true

      @log.info("Connecting to #{@hostname}:#{@port}")
      ssl_sock.connect
      @log.debug("Request:\n#{xml}")
      ssl_sock.puts("#{xml}\r\n")
      response = ""
      while line = ssl_sock.gets
        response += line
      end
      ssl_sock.close

      response
    end

    def parse_response(xml, command)
      @log.debug("Response:\n#{xml}")

      # ILO sends back multiple XML documents, split by XML header
      messages = xml.split(/<\?xml.*?\?>\r?\n/)
      # first is empty since string begins with XML header
      messages.shift

      output = {}
      #TODO manage status output
      output[:status] = []

      messages.each do |doc|
        xml_doc = Nokogiri::XML(doc){|cfg| cfg.nonet.noblanks}

        xml_doc.root.children.each do |node|
          case node.name
          when "RESPONSE"
            code = node.attr("STATUS").to_i(16)
            message = node.attr("MESSAGE")
            output[:status] << { :code => code, :message => message }
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

      output[:status].uniq!
      output
    end

    def ribcl_request(command, args = {})
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.ribcl(:version => "2.0") {
          xml.login(:password => @password, :user_login => @login) {
            xml.send(@ribcl.get_context(command), :mode => @ribcl.get_mode(command)) {
              xml.send(command, args) {
              }
            }
          }
        }
      end

      builder.to_xml
    end

    def parse_value(value)
      case value
      when /^Y$/i
        true
      when /^N$/i
        false
      else
        value
      end
    end

    def setup_commands
      @ribcl = HP::RIBCL.new
      Dir.glob(File.join(File.dirname(__FILE__), "definitions", "*.rb")).each do |file|
        @log.info("Loading #{file} command file")
        @ribcl.instance_eval(File.read(file), file)
      end
      nil
    end

    def fu(message)
      @log.error(message)
      raise message
    end
  end
end
