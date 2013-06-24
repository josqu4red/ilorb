require 'socket'
require 'openssl'
require 'net/https'
require 'nokogiri'
require 'json'

module HP
  class ILO
    def initialize(config = {})
      @hostname = config[:hostname]
      @login = config[:login] || "Administrator"
      @password = config[:password]
      @port = config[:port] || 443

      @ribcl_path = "/ribcl"
      @verify_ssl = false

      # TODO better choice
      @protocol = :http
    end

    # TODO more tests (args, etc)
    def method_missing(name, *args, &block)
      request = ribcl(RIBCL[name][:context], RIBCL[name][:mode], name)
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

    def send_http_request(xml)
      https = Net::HTTP.new(@hostname, @port)
      https.use_ssl = true
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE unless @verify_ssl
      response = https.post(@ribcl_path, xml)
      if response.is_a?(Net::HTTPNotFound)
        @protocol = :raw
        send_raw_request(xml)
      else
        response.body
      end
    end

    def send_raw_request(xml)
      sock = TCPSocket.new(@hostname, @port)

      ctx = OpenSSL::SSL::SSLContext.new(:TLSv1)
      ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
      ssl_sock = OpenSSL::SSL::SSLSocket.new(sock, ctx)
      ssl_sock.sync_close = true
      ssl_sock.connect

      ssl_sock.puts("#{xml}\r\n")
      response = ""
      while line = ssl_sock.gets
        response += line
      end
      ssl_sock.close

      response
    end

    # TODO find sane notation for XML -> hash
    def parse_response(xml, command)
      # ILO sends back multiple XML documents, split by XML header
      messages = xml.split(/<\?xml.*?\?>\r?\n/)

      # first is empty since string begins with XML header
      messages.shift

      output = {}

      messages.each do |doc|
        xml_doc = Nokogiri::XML(doc){|cfg| cfg.nonet.noblanks}

        xml_doc.root.children.each do |node|
          case node.name
          when "RESPONSE"
            begin
              check_response_status(node)
            rescue Exception => e
              puts e.message
            end
          when "INFORM"
            # OSEF
          else # command result
            if node.children.length > 0
              node.children.each do |child|
                if child.attributes.length == 1 and child.has_attribute?("VALUE")
                  output[child.name.downcase] = parse_value(child.attr("VALUE"))
                else
                  output[child.name.downcase] = {}
                  child.each do |key,val|
                    output[child.name.downcase][key.downcase] = parse_value(val)
                  end
                end
              end
            end

            if node.attributes.length > 0
            end
          end
        end
      end

      puts JSON.pretty_generate(output)
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
