%w(firewalld apache mysql tomcat gitbucket jenkins).each do |cookbook|
  include_recipe "../cookbooks/#{cookbook}/default.rb"
end
