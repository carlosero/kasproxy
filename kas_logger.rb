# ++++++ #
# LOGGER #
# ------ #

require 'logger'
class KasLogger
  @logger = nil
  def initialize(params={})
    # @logger = Logger.new(File.expand_path('../log.txt', __FILE__))
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::INFO
  end

  def log(msg = "")
    @logger.info(msg)
  end

  def error(msg = "")
    @logger.error(msg)
  end

  def close
    @logger.close
  end
end
