class User < ActiveRecord::Base
	@@connections=nil
	@@access_token =Authorize.get_access_token;
def self.get_values
	access_token= @@access_token;

  	response = access_token.get('https://api.linkedin.com/v1/people/~/connections?format=json')
  	 #Hash
    
   
    #self_conn = access_token.get('https://api.linkedin.com/v1/people/<ID>:(relation-to-viewer:(related-connections))?format=json')
    #self_conn_body = JSON.parse self_conn.body
    #puts self_conn_body
     case response
              when Net::HTTPUnauthorized
                # Handle 401 Unauthorized response
              when Net::HTTPForbidden
                # Handle 403 Forbidden response
    end
    
  	@@connections = JSON.parse response.body
  	#puts @@connections[]
  	return @@connections.values[3]
end

def self.currentUser
	access_token= @@access_token;
	self_response = access_token.get('https://api.linkedin.com/v1/people/~:(location,industry,headline)?format=json')
    self_body = JSON.parse self_response.body

end
def self.ordercontacts
	contacts=User.get_values
	contacts=Hash[contacts.map { |r| [r['id'], r] }]
	
	cUser= User.currentUser
	cUser['headline']=cUser['headline'].split(' at ')
	#puts cUser['industry'].split;
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
	
	contacts.keys.each do |cohash|
		#puts 'before' + contacts[cohash]['score'].to_s
		self_conn = @@access_token.get('https://api.linkedin.com/v1/people/'+cohash+':(relation-to-viewer:(related-connections))?format=json')
    	self_conn_body = JSON.parse self_conn.body
    	self_conn_body= self_conn_body["relationToViewer"]["relatedConnections"]["values"]
    	if !self_conn_body.nil? then
    		#puts self_conn_body

    	#self_conn_body=self_conn_body["relationToViewer"]["relatedConnections"]#["values"]
    	#puts self_conn_body
    	self_conn_body.map{|subhash| 
    		#puts contacts[cohash]['score']
    		mutcont = contacts[subhash['id']] 
    		contacts[cohash]['score']+=mutcont['score'] if !mutcont.nil?
    	}
    	end
    	#puts contacts[cohash]['score']
	end
	contacts = contacts.values.sort_by do |con| [con['score'], con['firstName']] end;

	return contacts.reverse
end
end
