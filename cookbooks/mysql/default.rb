package 'mariadb-server'

service 'mariadb' do
  action [:start, :enable]
end
