require 'spec_helper'

describe 'netbox::database' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          database_name: 'testdb',
          database_user: 'testdbuser',
          database_password: 'testdbpass',
        }
      end

      it { is_expected.to compile }
    end
  end
end
