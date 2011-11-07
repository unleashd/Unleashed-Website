##
# Active Record session model to be stored/retrieved from the database.
#
require 'rubygems'
require 'active_record'

class Session < ActiveRecord::Base
    belongs_to :user
    
    def self.create_for(user)
        session = Session.new
        session.user = user;
        session.id = rand_alphanum(40)
        return session;
    end
    
    private
    #
    # Generate a string of n fairly random alphanumeric characters.
    #
    def self.rand_alphanum(n)
        Array.new(n/2 + n%2){Kernel.rand(256)}.pack('C*').unpack('H*').first.slice(0, n)
    end
end
