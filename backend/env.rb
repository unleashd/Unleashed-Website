#
# Backend environment configuration.
#

#
# Point rubygems at the correct place.
#
ENV['GEM_HOME'] = File.join(ENV['HOME'], "gems")

#
# Add the lib directory to the load path.
#
$LOAD_PATH << File.join(File.dirname(__FILE__), "lib");

BACKEND_DIR = File.dirname(__FILE__)
CREDENTIALS_FILE = File.expand_path(File.join(BACKEND_DIR, "conf", "db-credentials.yaml"))
DROPBOX_SESSION_FILE = File.expand_path(File.join(BACKEND_DIR, "conf", "dropbox-session.yaml"))

