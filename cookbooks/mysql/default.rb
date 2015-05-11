package 'mariadb-server'

service 'mariadb' do
  action [:start, :enable]
end

remote_file "/etc/my.cnf"

execute "mysql_secure_installation" do
  user "root"
  only_if "mysql -u root -e 'show databases' | grep information_schema" # パスワードが空の場合
  command <<-EOL
    mysqladmin -u root password "password"
    mysql -u root -ppassword -e "DELETE FROM mysql.user WHERE User='';"
    mysql -u root -ppassword -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1');"
    mysql -u root -ppassword -e "DROP DATABASE test;"
    mysql -u root -ppassword -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
    mysql -u root -ppassword -e "FLUSH PRIVILEGES;"
  EOL
end
