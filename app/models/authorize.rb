class Authorize < ActiveRecord::Base
@@access_token
def self.new_client(key, secret)
	OAuth2::Client.new(
       key, 
       secret, 
       :authorize_url => "/uas/oauth2/authorization?response_type=code", #LinkedIn's authorization path
       :token_url => "/uas/oauth2/accessToken", #LinkedIn's access token path
       :site => "https://www.linkedin.com"
     )
end


def self.get_token(client,code,redirect_uri)
	token = client.auth_code.get_token(code, :redirect_uri => redirect_uri)
           
            #Use token object to create access token for user 
            #Note how we're specifying that the access token be passed in the header of the request
    @@access_token = OAuth2::AccessToken.new(client, token.token, {
              :mode => :header,
              :header_format => 'Bearer %s'
             })

    
    return @@access_token

end	

def self.get_access_token
	return @@access_token
end
end
