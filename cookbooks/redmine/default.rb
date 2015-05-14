execute "svn co http://svn.redmine.org/redmine/branches/3.0-stable /var/lib/redmine" do
    not_if "test -e /var/lib/redmine"
end

remote_file "/var/lib/redmine/config/database.yml"

# execute "sudo sed -i 's/^Defaults\\s*secure_path\\s*=.*/Defaults secure_path = \\/sbin:\\/bin:\\/usr\\/sbin:\\/usr\\/bin:\\/usr\\/local\\/bin/' /etc/sudoers"

%w(mariadb-server ruby).each do |p|
    package p
end

execute "create db and user for redmine" do
    command <<-EOL
    mysql -u root -ppassword -e "create database db_redmine default character set utf8;"
    mysql -u root -ppassword -e "grant all on db_redmine.* to user_redmine@localhost identified by 'password';"
    mysql -u root -ppassword -e "create database db_redmine default character set utf8;"
    mysql -u root -ppassword -e "flush privileges;"
    EOL
end

execute "gem install passenger --no-rdoc --no-ri -v 5.0.7"

# passenger-install-apache2-module/bundle install に必要なもの
%w(libcurl-devel openssl-devel zlib-devel httpd-devel ruby-devel apr-devel
apr-util-devel mariadb-devel ImageMagick ImageMagick-devel).each do |p|
    package p
end

execute "migration" do
    command <<-EOL
        cd /var/lib/redmine
        gem install bundler
        /usr/local/bin/bundle install
        RAILS_ENV=production /usr/local/bin/rake db:migrate
        /usr/local/bin/rake generate_secret_token
    EOL
end

#execute "migration" do
#    command <<-EOL
#    export ORIG_PATH="$PATH"
#    sudo -s -E
#    export PATH="$ORIG_PATH"
#    /usr/bin/ruby /usr/local/share/gems/gems/passenger-5.0.7/bin/passenger-config --detect-apache2
#    EOL
#end

execute "/usr/local/bin/passenger-install-apache2-module --auto"

execute "sudo chown -R apache:apache /var/lib/redmine"

execute "sudo ln -s /var/lib/redmine/public /var/www/html/redmine"

remote_file "/etc/httpd/conf.d/redmine.conf"

execute 'sudo sed -ie "s/Options Indexes FollowSymLinks/# Options -Indexes FollowSymLinks/g" /etc/httpd/conf/httpd.conf'

service 'httpd' do
  action [:restart]
end
