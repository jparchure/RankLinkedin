class User < ActiveRecord::Base
	@@connections=nil
	@@access_token =Authorize.get_access_token;
def self.hash_with_default_hash
    Hash.new { |hash, key| hash[key] = hash_with_default_hash }
end


def self.get_values
	access_token= @@access_token;
	#Make the api call to get all connections
  	response = access_token.get('https://api.linkedin.com/v1/people/~/connections?format=json')

     case response
              when Net::HTTPUnauthorized
                # Handle 401 Unauthorized response
              when Net::HTTPForbidden
                # Handle 403 Forbidden response
    end
    #Store response body
  	@@connections = JSON.parse response.body
  	#Return list of user connections
  	return @@connections.values[3]
end

def self.currentUser
	access_token= @@access_token;
	#Get the location, industry and headline of current user
	self_response = access_token.get('https://api.linkedin.com/v1/people/~:(location,industry,headline)?format=json')
    self_body = JSON.parse self_response.body

end
def self.ordercontacts
	#Get list of user contacts
	contacts=User.get_values
	#Convert the list of user contacts to a hash
	contacts=Hash[contacts.map { |r| [r['id'], r] }]
	#The current user
	cUser= User.currentUser
	#Get information of the organization at which current user works
	cUser['headline']=cUser['headline'].split(' at ')
	#Get information of the organization that user contacts work
	contacts.values.each do |co| 
		co['headline']= co['headline'].split(' at ')
		co['score']=0
	end
	contacts.values.each do |co|
		#If headline is composed of multiple words, assign score based on
		#The number of word matches
		co['score']=co['score'] + 0.5 * (co['headline'] & cUser['headline']).length
		#Assign a score if in same industry
		co['score']+=1 if co['industry'] .eql? cUser['industry']
		#Assign a score based on location
		co['score']+=1 if co['location']['name'].eql? cUser['location']['name']
	end
	temphash=User.hash_with_default_hash
	index=0
	contacts.keys.each do |cohash|
		#Get list of mutual contacts for each connection
		self_conn = @@access_token.get('https://api.linkedin.com/v1/people/'+cohash+':(relation-to-viewer:(related-connections))?format=json')
    	self_conn_body = JSON.parse self_conn.body
    	self_conn_body= self_conn_body["relationToViewer"]["relatedConnections"]["values"]
    	if !self_conn_body.nil? then #Exclude people with no other mutual contacts
    	self_conn_body.map{|subhash| 
    		#Get the contact id
    		mutcont = contacts[subhash['id']] 
    		#puts mutcont
    		#Add the score of the contact to current score
    		if !mutcont.nil? then #Store in a temporary hash, the updated score
    				temphash[cohash]['score']=contacts[cohash]['score'] + 0.1 * mutcont['score'] 
    		
    		end
    	}
    	end
    	end
    

    	contacts.keys.each do |key|
    	contacts[key]['score'] = temphash[key]['score'] if temphash[key]['score'].is_a? Float
    	#Update the original score with the new one
		end

		
	#Sort first by score and then by firstName
	contacts = contacts.values.sort_by do |con| [con['score'], con['firstName']] end
	#Return sorted descended
	return contacts.reverse
	end

end
