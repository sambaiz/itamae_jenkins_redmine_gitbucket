package 'httpd'

# index.htmlなどがないときにファイル一覧が表示されなくする
execute 'sudo sed -ie "s/Options Indexes FollowSymLinks/# Options -Indexes FollowSymLinks/g" /etc/httpd/conf/httpd.conf'

service 'httpd' do
  action [:start, :enable]
end

%w(http).each do |service|
  execute "sudo firewall-cmd --zone public --add-service #{service} --permanent" do
    not_if "sudo firewall-cmd --list-service --zone=public | grep ' #{service} '"
  end
end

# 再起動して設定を適用
execute "firewall-cmd --reload"
