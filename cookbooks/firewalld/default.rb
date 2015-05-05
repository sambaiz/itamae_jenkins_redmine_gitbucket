package 'firewalld'

service 'firewalld' do
  action [:start, :enable]
end
