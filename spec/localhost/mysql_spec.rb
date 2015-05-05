require 'spec_helper'

describe package('mariadb') do
  it { should be_installed }
end

describe service('mariadb') do
  it { should be_enabled }
  it { should be_running }
end
