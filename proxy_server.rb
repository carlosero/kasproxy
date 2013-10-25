# ++++++++++++ #
# PROXY SERVER #
# ------------ #
estu wall
require 'socket'
require 'timeout'

class ProxyServer
  PORT = 8000
  CONNECTION_TIMEOUT = 600 # seconds
  CSV_CHAR = ","
  ERROR_TYPE = {
    :no_founds => '1',
    
  }
  FORMAR_SUCCESS = "S:CSV_CHAR:TX_ID"
  FORMAR_ERROR = "E:CSV_CHAR:ERROR_TYPE"
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
  def interpretate(str)
    values = str.split(CSV_CHAR)
    serial = values[0]
    type_tx = values[1]
    customer_id = values[2]
    ammount = values[3]
    type_account = values[4]
    transaction_id = values[5]
    mac_challenge = values[6]
    mac = values[7]
    # Los campos que irán en el JSON que enviará el POS son
    # POS ID, Type TX, Customer ID, Monto, Type Count, TX ID, MAC Challenge, MAC
    # Lo que necesito recibir de la APP es: Rechazado en caso de ser rechazada la operación y Aprobado, Customer ID, Monto, TX ID y MAC en caso 
    # de ser aprobado.
    # El TX ID es el transaction ID que genera la APP para cada operación
    # En todos los casos el MAC está al final indicando que toma todos los valores de los campos anteriores y le calcula el SHA1.
    str
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


