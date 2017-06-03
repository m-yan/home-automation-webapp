class HgwIfRequestor
  attr_reader :response, :result_status  

  def initialize(uri, method, body=nil)
    @uri = uri
    @method = method
    @body = body
  end

  def send_request
    header = { 'Accept': 'application/xml',
               'Accept-Charset': 'utf-8',
               'X-M2M-Origin': X_M2M_ORIGIN,
               'X-M2M-RI': Time.current.strftime('%m%d%H%M%S') << SecureRandom.hex(10)
              }

    http_client = HTTPClient.new(default_header: header)
    http_client.set_auth(@uri, HGW_DIGEST_USER, HGW_DIGEST_PASSWORD)

    case @method.to_sym
    when :post
      response = http_client.post(@uri, @body, { 'Content-Type': 'application/xml; charset=utf-8' })
    when :get
      response = http_client.get(@uri)
    end
    @result_status = response.status
    @response = response.content

    case @result_status.to_s
    when /^2/
      return true
    else
      return false
    end
  end

end
