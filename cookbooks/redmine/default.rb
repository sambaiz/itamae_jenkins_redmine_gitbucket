execute "svn co http://svn.redmine.org/redmine/branches/3.0-stable /var/lib/redmine" do
    not_if "test -e /var/lib/redmine"
end

remote_file "/var/lib/redmine/config/database.yml"
