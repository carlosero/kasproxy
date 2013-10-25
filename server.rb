require File.expand_path("../kashaz", __FILE__)
require File.expand_path("../kas_logger", __FILE__)
require File.expand_path("../proxy_server", __FILE__)

#begin
  logger = KasLogger.new
  logger.log("Starting Kashaz Proxy server")
  logger.log("Kashaz-Pos URL: #{Kashaz::KASHAZ_URL}")
  logger.log("SERVER URL: #{ProxyServer.ip_address}")
  logger.log("SERVER PORT: #{ProxyServer::PORT}")
  server = ProxyServer.new
  server.start_server
#ensure
  logger.close
#end
