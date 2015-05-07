execute "sudo wget https://github.com/takezoe/gitbucket/releases/download/3.1.1/gitbucket.war -P /var/lib/tomcat/webapps" do
    not_if "test -e /var/lib/tomcat/webapps/gitbucket.war"
end
remote_file "/etc/httpd/conf.d/gitbucket.conf"
execute "sudo setenforce 0"
execute "sudo sed -i s/SELINUX=enforcing/SELINUX=disabled/ /etc/sysconfig/selinux"

%w(tomcat httpd).each do |s|
    service s do
        action [:restart]
    end
end
