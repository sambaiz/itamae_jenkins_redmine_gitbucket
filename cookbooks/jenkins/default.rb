execute "sudo wget http://mirrors.jenkins-ci.org/war/latest/jenkins.war -P /var/lib/tomcat/webapps" do
    not_if "test -e /var/lib/tomcat/webapps/jenkins.war"
end
remote_file "/etc/httpd/conf.d/jenkins.conf"
execute "sudo setenforce 0"
execute "sudo sed -i s/SELINUX=enforcing/SELINUX=disabled/ /etc/sysconfig/selinux"

%w(tomcat httpd).each do |s|
    service s do
        action [:restart]
    end
end
