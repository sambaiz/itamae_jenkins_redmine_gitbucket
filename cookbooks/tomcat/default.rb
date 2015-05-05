package 'tomcat'

service 'tomcat' do
  action [:start, :enable]
end
