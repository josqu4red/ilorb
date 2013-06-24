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
    end

    def do(command, params = {})
      if RIBCL.has_key?(command.to_sym)
        puts @hostname
        xml_req = ribcl(RIBCL[command][:context], RIBCL[command][:mode], command)
        puts xml_req
        xml_resp = send_request(xml_req)
      #  puts xml_resp
      #  parse_response(xml_resp, command)
      else
        puts "No such command: #{command}"
      end
    end

    private

    #def send_request(xml)
    #  https = Net::HTTP.new(@hostname, @port)
    #  https.use_ssl = true
    #  https.verify_mode = OpenSSL::SSL::VERIFY_NONE unless @verify_ssl
    #  response = https.post(@ribcl_path, xml)
    #  response.body
    #end

    def send_request(xml)
      puts http_post(xml)
#      sock = TCPSocket.new(@hostname, @port)
#
#      #ssl_ctx = OpenSSL::SSL::SSLContext.new(:TLSv1)
#      #ssl_ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
#      #ssl_sock = OpenSSL::SSL::SSLSocket.new(sock) #, ssl_ctx)
#      #ssl_sock.sync_close = true
#      #ssl_sock.connect
#
#      puts "puts"
#      sock.write(xml)
#      puts "gets"
#      while line = sock.gets
#        puts line
#      end
    end

    def parse_response(xml, command)
      # ILO sends back multiple XML documents, split by XML header
      messages = xml.split(/<\?xml.*?\?>\r?\n/)

      # first is empty since string begins with XML header
      messages.shift

      output = {}

      messages.each do |doc|
        xml_doc = Nokogiri::XML(doc){|cfg| cfg.nonet.noblanks}

        begin
          check_response_status(xml_doc)
        rescue Exception => e
          puts e.message
        end

        nodes = xml_doc.xpath("//#{command.upcase}/child::node()")

        next if nodes.empty?

        nodes.each do |node|
          if node.attributes.length == 1 and node.has_attribute?("VALUE")
            output[node.name.downcase] = parse_value(node.attr("VALUE"))
          else
            output[node.name.downcase] = {}
            node.each do |key,val|
              output[node.name.downcase][key.downcase] = parse_value(val)
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

      builder.doc.root.to_s
    end

    def check_response_status(xml_doc)
      response = xml_doc.xpath("//RESPONSE")
      unless response.empty?
        n = response.first
        raise "#{n.attr("MESSAGE")} (#{n.attr("STATUS")})" unless n.attr("STATUS").to_i(16) == 0
      end
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

    def http_post(xml)
      str = <<POST
POST #{@ribcl_path} HTTP/1.1
Host: localhost
Content-Length: #{xml.length}
Connection: close


POST
      str
    end
  end
end
