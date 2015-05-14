package 'httpd'

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
