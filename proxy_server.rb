# ++++++++++++ #
# PROXY SERVER #
# ------------ #
require 'socket'
require 'timeout'
require File.expand_path("../kashaz", __FILE__)

class ProxyServer
  PORT = 8000
  CONNECTION_TIMEOUT = 600 # seconds
  @logger = nil
  @server = nil

  def initialize(logger = KasLogger.new)
    @logger = logger
    @server = TCPServer.open(PORT)
  end

  def self.ip_address
    addr = Socket.ip_address_list.detect{|intf| intf.ipv4? and !intf.ipv4_loopback? and !intf.ipv4_multicast? and !intf.ipv4_private?}
    addr.ip_address
  end

  # should go to kas and response something
  def interpretate(request)
    @logger.log("request = #{request}")
    @logger.log("request.length = #{request.length}")
    # now kashaz-pos will handle everything, we just send and response
    response = Kashaz.send_request(request)
    response["response"]
  end

  def handle_incomming_data(incomingData, connection)
    if incomingData != nil
      incomingData = incomingData.chomp
      incomingData = incomingData.strip
    end

    @logger.log "Incoming: #{incomingData}" unless incomingData.nil? || incomingData == ""

    if incomingData == "DISCONNECT"
      @logger.log "Received: DISCONNECT, closing connection"
      connection.close
    else
      unless incomingData.nil? || incomingData == ""
          respond_data = interpretate(incomingData)
          @logger.log "Sending:  #{respond_data}"
          connection.puts respond_data 
       end
      connection.flush
    end
  end

  def start_server
      
    loop do
      Thread.new(@server.accept) do |connection|
        @logger.log "Accepting connection from: #{connection.peeraddr[2]}"

        begin
          Timeout.timeout(CONNECTION_TIMEOUT) do 
            while connection
              incomingData = connection.gets
              handle_incomming_data(incomingData, connection)
            end # while connection
          end # timeout
        rescue Exception => e
          # Displays Error Message
          @logger.error "#{ e } (#{ e.class })"
        ensure
          connection.close
          @logger.error "ensure: Closing"
        end
      end
    end

  end


end


