# +++++++++++++++++++++ #
# KASHAZ-POS CONNECTION #
# --------------------- #

require 'net/http'
class Kashaz
  KASHAZ_URL = "http://localhost:3333"
  GENERATE_KEY_URL = "#{KASHAZ_URL}/poses/generate_key?"
  VALIDATE_KEY_URL = "#{KASHAZ_URL}/poses/validate_key?"

  class << self
    def generate_key(serial)
      get(GENERATE_KEY_URL, {serial: serial})
    end

    def validate_key(key)
      get(VALIDATE_KEY_URL, {key: key})
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
       str += str.blank? ? "#{k}=#{v}" : "&#{k}=#{v}"
    end
  end
end
