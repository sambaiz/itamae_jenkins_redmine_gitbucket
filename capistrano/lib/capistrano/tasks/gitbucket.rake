namespace :gitbucket do
    task :deploy do
      on roles(:app) do |s|
        execute "sudo wget http://mirrors.jenkins-ci.org/war/latest/jenkins.war -P /var/lib/tomcat/webapps"
        upload! "file/apache/gitbucket.conf, /tmp/gitbucket.conf"
        execute "sudo mv /tmp/gitbucket.conf /etc/httpd/conf.d/gitbucket.conf"
        execute "sudo sed -i s/SELINUX=enforcing/SELINUX=disabled/ /etc/sysconfig/selinux"
        execute "sudo systemctl restart tomcat"
        execute "sudo systemctl restart httpd"
      end
    end
end
