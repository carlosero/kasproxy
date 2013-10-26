# +++++++++++++++++++++ #
# KASHAZ-POS CONNECTION #
# --------------------- #

require 'net/http'
require 'active_support'
class Kashaz
  KASHAZ_URL = "http://localhost"
  GENERATE_KEY_URL = "#{KASHAZ_URL}/poses/generate_key?"
  AUTHENTICATE_URL = "#{KASHAZ_URL}/poses/authenticate?"

  class << self
    def generate_key(serial)
      get(GENERATE_KEY_URL, {serial: serial})
    end

    def authenticate(key)
      get(AUTHENTICATE_URL, {key: key})
    end

    def get(url, params = {})
      url = URI.parse(url)
      url.query = params.to_query
      resp = Net::HTTP.get_response url
      ActiveSupport::JSON.decode(resp.body) rescue resp.body
    end
  end
end

class Hash
  def to_query
    inject("") do |str,(k,v)|
       str += str == "" ? "#{k}=#{v}" : "&#{k}=#{v}"
    end
  end
end
