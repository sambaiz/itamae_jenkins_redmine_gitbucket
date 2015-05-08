execute "svn co http://svn.redmine.org/redmine/branches/3.0-stable /var/lib/redmine" do
    not_if "test -e /var/lib/redmine"
end

remote_file "/var/lib/redmine/config/database.yml"
remote_file "/etc/httpd/conf.d/redmine.conf"

execute "sudo sed -i 's/^Defaults\\s*secure_path\\s*=.*/Defaults secure_path = \\/sbin:\\/bin:\\/usr\\/sbin:\\/usr\\/bin:\\/usr\\/local\\/bin/' /etc/sudoers"

%w(mariadb-server mariadb-devel httpd-devel ruby ruby-devel openssl-devel
readline-devel zlib-devel curl-devel libyaml-devel libffi-devel libxml2-devel
libxslt-devel ImageMagick ImageMagick-devel ipa-pgothic-fonts).each do |p|
    package p
end

execute "migration" do
    command <<-EOL
        cd /var/lib/redmine
        gem install bundler
        bundle install
        RAILS_ENV=production rake db:migrate
    EOL
end
