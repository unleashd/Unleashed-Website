
require 'dropbox'

module UnleashdDropbox
    
    def self.initialize!(session)
        @@session = Dropbox::Session.deserialize(session)
    end
    
    MUSIC_PATH = '/Unleashed Website Music'

    def self.list
        entries = @@session.list(MUSIC_PATH)
        files = entries.select{|e| !e.directory?}
        directories = entries.select{|e| e.directory?}
        return files.map do |file|
            path = file.path.match(%r{^#{MUSIC_PATH}/(.*?)$}).captures.first
            song_name = File.basename(path, File.extname(path))
            {
                :name => song_name,
                :path => path
            }
        end
    end
    
    def self.download(filename)
        pathname = File.join(MUSIC_PATH, filename)
        @@session.download(pathname)
    end
    
    def self.metadata(filename)
        pathname = File.join(MUSIC_PATH, filename)
        @@session.metadata(pathname)
    end
end
