%w(firewalld apache mysql tomcat).each do |cookbook|
  include_recipe "../cookbooks/#{cookbook}/default.rb"
end
