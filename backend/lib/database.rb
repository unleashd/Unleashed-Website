##
# Database connection logic.
#
# Credentials are stored in db-credentials.yaml and should be readable only by
# the unleashd user.
#
module Database
    # Settings should match those in MySQL configuration file $HOME/.my.cnf
    HOST = 'vergil.u.washington.edu'
    PORT = 30334

    ##
    # Connect ActiveRecord to the mysql database.
    #
    def self.connect!(credentials)
        require 'yaml'
        require 'rubygems'
        require 'active_record'
    
        credentials = 
        raise "Unable to find/load credentials file." unless credentials and credentials['username'] and credentials['password']
        ActiveRecord::Base.establish_connection(
                :adapter  => 'mysql',                 :database => 'unleashed',
                :host     => HOST,                    :port     => PORT,
                :username => credentials['username'], :password => credentials['password'],
                :reconnect => true)
    end
end
