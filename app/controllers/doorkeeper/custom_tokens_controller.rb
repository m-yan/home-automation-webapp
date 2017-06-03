class Doorkeeper::CustomTokensController < Doorkeeper::TokensController

    def create
      response = authorize_response

      body = response.body
      body.delete 'created_at'

      headers.merge! response.headers
      self.response_body = body.to_json
      self.status        = response.status
    rescue Errors::DoorkeeperError => e
      handle_token_exception e
    end

end
