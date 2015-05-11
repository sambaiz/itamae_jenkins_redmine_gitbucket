execute "svn co http://svn.redmine.org/redmine/branches/3.0-stable /var/lib/redmine" do
    not_if "test -e /var/lib/redmine"
end

remote_file "/var/lib/redmine/config/database.yml"
# remote_file "/etc/httpd/conf.d/redmine.conf"

execute "sudo sed -i 's/^Defaults\\s*secure_path\\s*=.*/Defaults secure_path = \\/sbin:\\/bin:\\/usr\\/sbin:\\/usr\\/bin:\\/usr\\/local\\/bin/' /etc/sudoers"

%w(mariadb-server mariadb-devel httpd-devel ruby ruby-devel openssl-devel
readline-devel zlib-devel curl-devel libyaml-devel libffi-devel libxml2-devel
libxslt-devel ImageMagick ImageMagick-devel ipa-pgothic-fonts).each do |p|
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

execute "migration" do
    command <<-EOL
        cd /var/lib/redmine
        gem install bundler
        bundle install
        RAILS_ENV=production rake db:migrate
        rake generate_secret_token
    EOL
end

execute "gem install passenger --no-rdoc --no-ri"

package "rubygem-rake"
execute "passenger-install-apache2-module --auto"

execute "sudo chown -R apache:apache /var/lib/redmine"

execute "sudo ln -s /var/lib/redmine/public /var/www/html/redmine"

execute 'sudo sed -ie "s/Options Indexes FollowSymLinks/# Options -Indexes FollowSymLinks/g" /etc/httpd/conf/httpd.conf'

service 'httpd' do
  action [:restart]
end
