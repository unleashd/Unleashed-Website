#! /usr/bin/env ruby
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# This file generates the XSFP playlists used by the XSFP Flash Player.
# The actual mp3s are uploaded to last.fm, so we'll get the html album page 
# from them, parse it for songs and urls and then output the playlist.
#
# @author spa
# @version 2009.9.18
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
begin

require 'net/http'
require 'cgi'
require 'uri'

TRACK_REGEXP = /<a href=".*?" album="">(.*?)<\/a>[\s\n]*<small>[\s\n]*<a href="(http:\/\/freedownloads\.last\.fm\/download\/.*?)">free download<\/a>/i

cgi = CGI.new
ALBUM = cgi.params['album'].first
url = URI.parse('http://www.last.fm/music/unleashed!+a+cappella/' << URI.escape(CGI.escapeHTML(ALBUM)))
tracks=[]
default_art=nil
Net::HTTP.new(url.host, url.port).start do |http|
    res = http.request(Net::HTTP::Get.new(url.path))
    tracks      = res.body.scan TRACK_REGEXP
    default_art = res.body.match(/<span id="albumCover" itemprop="image" class="albumCover coverMega"><img  width="174" src="(.*?)" class="art"/).captures.first    
end


# N.B.!  The tabs in the output below are important!  The xml parser on the 
# music player isn't all that great apparently.
puts "Content-type: application/xspf+xml"
puts
puts <<-END_XML
<?xml version="1.0" encoding="UTF-8"?>
<playlist version="1" xmlns="http://xspf.org/ns/0/">
	<title>Unleashed! - <%= CGI.escapeHTML(ALBUM) %></title>
	<creator>Unleashed! A Cappella</creator>
	<trackList>
	<%- tracks.each do |title, url| -%>
		<track>
			<location><%= CGI.escapeHTML(url) %></location>
			<title><%= CGI.escapeHTML(title.gsub(/.* - /, '')) %></title>
			<image><%= CGI.escapeHTML(default_art) %></image>
			<album><%= CGI.escapeHTML(ALBUM) %></album>
		</track>
	<%- end -%>
	</trackList>
</playlist>
END_XML
rescue Exception => e
    puts "Content-type: text/plain"
    puts e
    puts e.backtrace
end
