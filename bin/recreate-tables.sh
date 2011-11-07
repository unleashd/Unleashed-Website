#! /bin/sh

MYSQL=$HOME/bin/mysql
USERNAME=root
PASSWORD=SongB!rd

cat $HOME/etc/sql/create_users.sql    | $MYSQL -u $USERNAME -p $PASSWORD
cat $HOME/etc/sql/create_sessions.sql | $MYSQL -u $USERNAME -p $PASSWORD
cat $HOME/etc/sql/create_posts.sql    | $MYSQL -u $USERNAME -p $PASSWORD
