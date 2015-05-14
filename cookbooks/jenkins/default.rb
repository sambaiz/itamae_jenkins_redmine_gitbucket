# SELinuxをoffに
execute "setenforce 0"
execute "sudo sed -i s/SELINUX=enforcing/SELINUX=disabled/ /etc/sysconfig/selinux"

execute "sudo wget http://mirrors.jenkins-ci.org/war/latest/jenkins.war -P /var/lib/tomcat/webapps" do
    not_if "test -e /var/lib/tomcat/webapps/jenkins.war"
end
remote_file "/etc/httpd/conf.d/jenkins.conf"

%w(tomcat httpd).each do |s|
    service s do
        action [:restart]
    end
end

# 再起動を待つ
execute "sleep 30"

# gitとgitbucketのプラグインを入れる
execute "gwget http://localhost/jenkins/jnlpJars/jenkins-cli.jar -P /tmp" do
    not_if "test -e /tmp/jenkins-cli.jar"
end
execute "java -jar /tmp/jenkins-cli.jar -s http://localhost/jenkins/ install-plugin git gitbucket -deploy"
