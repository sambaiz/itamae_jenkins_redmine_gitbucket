namespace :jenkins do
    task :deploy do
      on roles(:app) do |s|
        system("itamae ssh -h #{s.hostname} -u #{s.user} ../roles/web.rb")
        execute "sudo wget http://mirrors.jenkins-ci.org/war/latest/jenkins.war -P /var/lib/tomcat/webapps"
        upload! "file/apache/jenkins.conf", "/tmp/jenkins.conf"
        execute "sudo mv /tmp/jenkins.conf /etc/httpd/conf.d/jenkins.conf"
        execute "sudo sed -i s/SELINUX=enforcing/SELINUX=disabled/ /etc/sysconfig/selinux"
        execute "sudo systemctl restart tomcat"
        execute "sudo systemctl restart httpd"
      end
    end
end
