##
# Active Record user model to be stored/retrieved from the database.
#
require 'rubygems'
require 'bcrypt'
require 'active_record'

class User < ActiveRecord::Base
    include BCrypt
    
    #
    # Get the user's encrypted password.  When compared with the actual password
    # using == the correct, hashed, comparison will be done.
    #
    def password
      @password ||= Password.new(password_hash)
    end

    #
    # Set the user's password. When actually saved to the database it will be
    # saved encrypted.
    #
    # new_password: a new password in plaintext
    #
    def password=(new_password)
      @password = Password.create(new_password)
      self.password_hash = @password
    end
end

