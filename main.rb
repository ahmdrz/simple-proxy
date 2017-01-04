require './proxy'
require './color'

if ARGV.empty?
  port = 8008
  savefile = ""
elsif ARGV.size == 1
  port = ARGV[0].to_i
  savefile = ""
elsif ARGV.size == 2
  port = ARGV[0].to_i
  savefile = ARGV[1]
else
  puts 'Usage: proxy.rb [port]'.red
  exit 1
end

puts ('Proxy server has been listened on ' + port.to_s).blue
if !savefile.empty?    
  puts ('Logs will be write on ' + savefile)
  proxy = Proxy.new port,open(savefile, 'w')
else
  proxy = Proxy.new port,nil
  end
proxy.run