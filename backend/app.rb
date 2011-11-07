#
# This is a ruby REST style application developed with Sinatra (http://www.sinatrarb.com/).
#
# It serves the dynamic content of the Unleashed A Cappella Website.
#
$LOAD_PATH << File.dirname(__FILE__)

require 'env'
require 'rubygems'
require 'database'
require 'json'
require 'session'
require 'sinatra'
require 'unleashd_dropbox'
require 'user'
require 'uw'

#
# Configure application. Run at application startup.
#
configure do
    set :port, 30333
    
    credentials = YAML.load(File.read(CREDENTIALS_FILE))
    Database.connect!(credentials)
    dropbox_session = File.read(DROPBOX_SESSION_FILE)
    UnleashdDropbox.initialize!(dropbox_session)
end

#
# Run for all routes.
#
before do
    # Set the default content type to be JSON.
    content_type 'application/json'
end

#
# APPLICATION ROUTE DEFINITIONS
#

#
# Authenticate and log the user into the website.
#
post '/login' do
    raise "Missing Authentication" unless params['username'] and params['password']
    username = params['username']
    password = params['password']
    
    user = User.find_by_username(username)
    return 'false' unless user
    
    is_authenticated = false
    cookies = {}
    case user.auth_type
    when 'uw'
        is_authenticated, cookies = UW.authenticated?(username, password)
    when 'non-uw'
        is_authenticated = (user.password == password)
    end
    
    return 'false' unless is_authenticated
    
    session = Session.create_for(user)
    session.save!
    
    JSON.generate(
        :auth_type => user.auth_type,
        :username => user.username,
        :cookies => cookies,
        :authtoken => session.id)
end

def authorized?(request)
    return false unless request.cookies['unleashd-authtoken']
    @session = Session.find(request.cookies['unleashd-authtoken'])
    return true if @session
end

#
# Check that the user is logged in (has a known session).
#
get '/check' do
    return 'false' unless authorized?(request)
    return JSON.generate({
        :username => @session.user.username,
        :is_admin => @session.user.is_admin?
    })
end

#
# List all the available sheet music.
#
get '/music/list' do
    raise 'Not Authorized' unless authorized?(request)
    JSON.generate(UnleashdDropbox.list)
end

#
# Get a specific file of sheet music.
#
get '/music/get/:filename' do
    raise 'Not Authorized' unless authorized?(request)
    metadata = UnleashdDropbox.metadata(params['filename'])
    content_type metadata.mime_type
    UnleashdDropbox.download(params['filename'])
end

#
# List all users.
#
get '/users/list' do
    raise 'Not Authorized' unless authorized?(request) and @session.user.is_admin?
    JSON.generate(User.find(:all).reject{|u| u.username == 'unleashd'}.map do |user|
        {
            :id => user.id,
            :username => user.username,
            :given_name => user.given_name,
            :surname => user.surname,
            :email => user.email,
            :auth_type => user.auth_type,
            :is_admin => user.is_admin?
        }
    end)
end

post '/users/:id/update' do
    raise 'Not Authorized' unless authorized?(request) and @session.user.id = params['id'] or @session.user.is_admin?
    
    user = User.find(params['id'])
    user.username = params['username']
    user.given_name = params['given_name']
    user.surname = params['surname']
    user.email = params['email']
    if @session.user.is_admin?
        user.is_admin = (params['is_admin'] == 'true' ? 1 : 0)
    end
    user.save!
    'true'
end

post '/users/:id/delete' do
    raise 'Not Authorized' unless authorized?(request) and @session.user.is_admin?
    User.delete(params['id'])
    'true'
end
