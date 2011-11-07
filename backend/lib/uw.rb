##
# Code for UWNetId authentication via Weblogin.
#
require 'uri'
require 'net/https'

class UW
    # Weblogin requires a known user agent for some reason.
    USER_AGENT = 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.1.6) ' <<
                 'Gecko/20091216 Fedora/3.5.6-1.fc11 Firefox/3.5.6'

    # Note, this should only be set when debugging from the command line. Data printed will 
    # mess up the login.cgi CGI script.
    DEBUG = false

    # Cookies to look for and send on during the login process.
    RECOGNIZED_COOKIES = ['pubcookie_l', 'pubcookie_g', 'pubcookie_s__unleashd_', 'uwauth']
    
    #
    # Attempts to log into a UWNetId protected page on behalf of the given
    # username and password and returns a tuple of:
    #
    # 1. Whether this log in was successful or not.
    # 2. Any cookies that were set during the login process.
    #
    def self.authenticated?(username, password)
        #
        # Make the actual requests in the sequence Weblogin expects.
        #
        _,    post_data, _      = request('https://students.washington.edu/unleashd/ajax/uw/protected')
        _,    post_data, _      = request('https://weblogin.washington.edu/', post_data)
        _,    post_data, cookie = request('https://weblogin.washington.edu/', post_data.merge({'user' => username, 'pass' => password }))
        _,    post_data, cookie = request('https://students.washington.edu/PubCookie.reply', post_data, cookie)
        body, post_data, cookie = request('https://students.washington.edu/unleashd/ajax/uw/protected', post_data, cookie)

        #
        # If we were successful, also return 'students.washington.edu' cookies that were set.
        #
        if body.match('true')
            return true, cookie
        else
            return false, nil
        end
    end
    
    private
    #
    # This method makes an HTTP request to the given url, optionally passing
    # some POST parameters and a string of one or more cookies.
    #
    # Returns, as a tuple:
    #  * the body of the response
    #  * a hash of field value => key for all inputs in all forms on the page
    #  * the cookie string for the first cookie set by the response
    #
    # This turns out to be just enough information to successfully navigate the
    # Weblogin system.
    #
    def self.request(url, post_data={}, cookies={})
        url = URI.parse(url)
        https = Net::HTTP.new(url.host, Net::HTTP.https_default_port)
        https.use_ssl = true
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE
        
        https.start do |http|
            req = Net::HTTP::Post.new(url.path)
            req['user-agent'] = USER_AGENT
            req['cookie'] = cookies.map{|k,v| "#{k}=#{v}"}.join('; ') unless cookies.empty?
            req.form_data = post_data unless post_data.empty?
            
            res = http.request(req)
            
            new_post_data = {}
            res.body.scan(/<input type="?hidden"? name="?(.*?)"? value="(.*?)">/).each do |match|
                new_post_data[match[0]] = match[1]
            end
            
            new_cookies = {}
            if res['Set-cookie']
                RECOGNIZED_COOKIES.each do |cookie_name|
                    match = res['Set-cookie'].match(/#{cookie_name}=(.*?);/)
                    new_cookies[cookie_name] = match.captures.first if match
                end
            end
            
            if DEBUG
                STDERR.puts "==============================================="
                STDERR.puts "Requested URL: #{url}"
                STDERR.puts "Requested POST data: #{post_data.inspect}"
                STDERR.puts "Requested Cookie: #{cookies.inspect}"
                STDERR.puts "------------------- RESPONSE ------------------"
                STDERR.puts "New POST data: #{new_post_data.inspect}"
                STDERR.puts "New Cookie: #{new_cookies.inspect}"
                #STDERR.puts "HEAD: #{res.to_hash.map{|k,v| "#{k}:#{v}"}.join("\n")}"
                #STDERR.puts "BODY: #{res.body}"
            end
            
            return res.body, new_post_data, new_cookies
        end
    end
end
