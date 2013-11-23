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
    def send_request(text)
      params = URI.escape(text)
      get("#{KASHAZ_URL}/interpretate?request=#{params}")
    end

    def get(url)
      url = URI.parse(url)
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
