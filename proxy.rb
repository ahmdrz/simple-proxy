require 'socket'
require 'uri'
require './color'

class Proxy    
  def initialize (port,file) 
    @port = port
    @file = file
    end
  def run
    begin
      @socket = TCPServer.new @port
      
      loop do
        s = @socket.accept        
        Thread.new s, &method(:handle_request)
      end
      
    # CTRL-C
    rescue Interrupt
      puts 'Interrupt'.red
    ensure
      if @socket
        puts 'Closing socket'.red
        @socket.close
        puts 'Socked closed'.green
      end
      puts 'Quitting.'.red
    end
  end
  
  def handle_request to_client
    request_line = to_client.readline
    
    verb    = request_line[/^\w+/]
    url     = request_line[/^\w+\s+(\S+)/, 1]
    version = request_line[/HTTP\/(1\.\d)\s*$/, 1]
    uri     = URI::parse url

    if !@file.nil? 
      @file.puts((" %4s "%verb) + url)
    else 
      puts(((" %4s "%verb) + url).blue)
      end
    
    to_server = TCPSocket.new(uri.host, (uri.port.nil? ? 80 : uri.port))
    to_server.write("#{verb} #{uri.path}?#{uri.query} HTTP/#{version}\r\n")
    
    content_len = 0
    
    loop do      
      line = to_client.readline
      
      if line =~ /^Content-Length:\s+(\d+)\s*$/
        content_len = $1.to_i
      end
      
      if line =~ /^proxy/i
        next
      elsif line.strip.empty?
        to_server.write("Connection: close\r\n\r\n")
        
        if content_len >= 0
          to_server.write(to_client.read(content_len))
        end
        
        break
      else
        to_server.write(line)
      end
    end
    
    buff = ""
    loop do
      to_server.read(4096, buff)
      to_client.write(buff)
      break if buff.size >= 4096
    end    
    
    to_client.close
    to_server.close
  end
  
end


