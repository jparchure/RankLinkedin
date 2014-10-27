class AuthorizeController < ApplicationController
API_KEY = '751v7beqwlotfs' #Your app's API key
  API_SECRET = '0peQbiqOpZlsmMW1' #Your app's API secret
  REDIRECT_URI = 'http://localhost:3000/accept' #Redirect users after authentication to this path, ensure that you have set up your routes to handle the callbacks
  STATE = SecureRandom.hex(15) #A unique long string that is not easy to guess
   
  #Instantiate your OAuth2 client object
  def client
    Authorize.new_client(API_KEY, API_SECRET)
  end
  
  def index
    authorize_user
  end
 
  def authorize_user
    #Redirect your user in order to authenticate
    redirect_to client.auth_code.authorize_url(:scope => 'r_fullprofile r_emailaddress r_network', 
                                               :state => STATE, 
                                               :redirect_uri => REDIRECT_URI)
  end
 
  # This method will handle the callback once the user authorizes your application
  def accept
      #Fetch the 'code' query parameter from the callback
          code = params[:code] 
          state = params[:state]
           
          if !state.eql?(STATE)
             #Reject the request as it may be a result of CSRF
          else          
            #Get token object, passing in the authorization code from the previous step 
            access_token = Authorize.get_token(client, code, REDIRECT_URI);
            redirect_to user_path;
            # Handle HTTP responses
            
        end
    end
 end

