package 'httpd'

service 'httpd' do
  action [:start, :enable]
end

%w(http).each do |service|
  execute "sudo firewall-cmd --zone public --add-service #{service}" do
    not_if "firewall-cmd --list-service --zone=public | grep ' #{service} '"
  end
end
