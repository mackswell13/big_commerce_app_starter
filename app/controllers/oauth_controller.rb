class OauthController < ApplicationController
  allow_unauthenticated_access
  include HTTParty

  def index
    values = oauth_params
    res = exchange_token(values)

    store = Store.new(token: res["access_token"], context: res["context"], scope: values[:scope])


    if store.save
      render plain: "Authed"
    else
      render palin: "Could not auth"
    end
  end


  def load
    signed_jwt = JWT::EncodedToken.new(load_params)

    signed_jwt.verify_signature!(algorithm: "HS256", key: Rails.application.credentials.bc_client_secret)
    signed_jwt.verify_claims!(:exp, :jti, :nbf)
    signed_jwt.verify_claims!(iss: [ "bc" ])
    payload = signed_jwt.payload

    # Login here
    store = Store.find_by(context: payload["sub"])
    user = User.find_or_create_by(email_address: payload["user"]["email"], bc_id: payload["user"]["id"], store_id: store.id)

    if payload["owner"]["email"] == user.email_address
      user.is_owner = true
      user.save
    end

    resume_or_restart_session_for user

    redirect_to dashboard_path
  end


  private

  def exchange_token(values)
    res = self.class.post("https://login.bigcommerce.com/oauth2/token",
            headers: { "Accept"=>"application/json", "Content-Type" => "application/json" },
            body: {
              client_id: Rails.application.credentials.bc_client_id,
              client_secret: Rails.application.credentials.bc_client_secret,
              code: values[:code],
              context: values[:context],
              scope: values[:scope],
              grant_type: "authorization_code",
              redirect_uri: "https://cockatoo-outgoing-leech.ngrok-free.app/oauth"
            }.to_json
          ).parsed_response
  end


  def oauth_params
    {
      code: params.require(:code),
      scope: params.require(:scope),
      context: params.require(:context),
      account_uuid: params.require(:account_uuid)
    }
  end

  def load_params
    params.require(:signed_payload_jwt)
  end
end
