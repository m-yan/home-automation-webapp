class NotificationHandler
  def self.send(message)
    body = {
              'title': 'HPE Home Automation Demo', 
              'body': message, 
              'icon': 'https://push7.jp/notifycation_icon.png',
              'url': 'http://13.78.50.153:10080/CSE0001/notifications',
              'apikey': '2043540fd92d4f98ade134a76b38c308'
           }

    http_client = HTTPClient.new
    response = http_client.post('https://api.push7.jp/api/v1/c105e2930f6d4efaaadee8d7129d990d/send', body.to_json, { 'Content-Type': 'application/xml; charset=utf-8' })

    result_status = response.status

    case result_status.to_s
    when /^2/
      return true
    else
      return false
    end
  end

end
