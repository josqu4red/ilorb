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
      @log.level = Logger::DEBUG
      #@log.level = config[:debug] ? Logger::DEBUG : Logger::WARN

      @nori = Nori.new(:convert_tags_to => lambda{|tag| tag.downcase.to_sym})
    end

    # TODO more tests (args, etc)
    def method_missing(name, *args, &block)
      request = ribcl(RIBCL[name][:context], RIBCL[name][:mode], name)
      @log.info("Calling #{name}")
      response = case @protocol
      when :http
        send_http_request(request)
      when :raw
        send_raw_request(request)
      end
      parse_response(response, name)
    end

    def respond_to(name)
      RIBCL.has_key?(name) ? true : super
    end

    private

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

      output = nil

      messages.each do |doc|
        xml_doc = Nokogiri::XML(doc){|cfg| cfg.nonet.noblanks}

        xml_doc.root.children.each do |node|
          case node.name
          when "RESPONSE"
            begin
              check_response_status(node)
            rescue Exception => e
              @log.error(e.message)
              return nil
            end
          when "INFORM"
            # OSEF
          else # actual result
            output = @nori.parse(node.to_s)
          end
        end
      end

      output
    end

    def ribcl(context, mode, command, args = nil, &block)
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.ribcl(:version => "2.0") {
          xml.login(:password => @password, :user_login => @login) {
            xml.send(context, :mode => mode) {
              xml.send(command, args) {
                yield xml if block_given?
              }
            }
          }
        }
      end

      builder.to_xml
    end

    def check_response_status(node)
      raise "#{node.attr("MESSAGE")} (#{node.attr("STATUS")})" unless node.attr("STATUS").to_i(16) == 0
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
  end
end
