require 'spec_helper'

describe 'kafka::client::config', :type => 'class' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { should compile.with_all_deps }
      it { should contain_file('/etc/kafka/conf/client.properties') }
      it { should contain_file('/etc/kafka/conf/consumer.properties') }
      it { should contain_file('/etc/kafka/conf/producer.properties') }
      it { should contain_file('/etc/kafka/conf/jaas-client.conf') }
    end
  end
end

describe 'kafka::client' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('kafka::params') }
      it { is_expected.to contain_class('kafka::client::install').that_comes_before('kafka::client::config') }
      it { is_expected.to contain_class('kafka::client::config') }
      it { should contain_package('kafka').with_ensure('present') }
    end
  end
end
