require 'spec_helper'

describe package('firewalld') do
  it { should be_installed }
end

describe service('firewalld') do
  it { should be_enabled }
  it { should be_running }
end

%w(80).each do |port_num|
  describe port(port_num) do
    it { should be_listening }
  end
end
