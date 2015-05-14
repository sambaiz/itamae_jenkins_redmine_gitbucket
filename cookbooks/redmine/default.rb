# SELinuxをoffに
execute "setenforce 0"
execute "sudo sed -i s/SELINUX=enforcing/SELINUX=disabled/ /etc/sysconfig/selinux"

execute "svn co http://svn.redmine.org/redmine/branches/3.0-stable /var/lib/redmine" do
    not_if "test -e /var/lib/redmine"
end

remote_file "/var/lib/redmine/config/database.yml"

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

gem_package "passenger" do
    version '5.0.7'
end

gem_package "bundler"


# passenger-install-apache2-module/bundle install に必要なもの
%w(libcurl-devel openssl-devel zlib-devel httpd-devel ruby-devel apr-devel
apr-util-devel mariadb-devel ImageMagick ImageMagick-devel).each do |p|
    package p
end

execute "migration" do
    command <<-EOL
        cd /var/lib/redmine
        /usr/local/bin/bundle install
        RAILS_ENV=production /usr/local/bin/rake db:migrate
        /usr/local/bin/rake generate_secret_token
    EOL
end

# PassengerのApache用モジュールのインストール
execute "/usr/local/bin/passenger-install-apache2-module --auto"

# Apacheを実行するユーザー・グループ("apache")が読み書きできるように権限を与える
execute "sudo chown -R apache:apache /var/lib/redmine"

# ApacheのDocumentRootに指定されているディレクトリにシンボリックリンクを張る
execute "sudo ln -s /var/lib/redmine/public /var/www/html/redmine" do
    not_if "test -e /var/www/html/redmine"
end

remote_file "/etc/httpd/conf.d/redmine.conf"

# redmine_github_hook pluginをインストール
git "/var/lib/redmine/plugins/redmine_github_hook" do
    repository "https://github.com/koppen/redmine_github_hook.git"
end

service 'httpd' do
  action [:restart]
end
