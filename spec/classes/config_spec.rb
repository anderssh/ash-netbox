require 'spec_helper'

describe 'netbox::config' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          user: 'testuser',
          group: 'testgroup',
          install_root: '/nonexistant',
          allowed_hosts: ['0.0.0.0/0'],
          database_name: 'testdb',
          database_user: 'testdbuser',
          database_password: 'testdbpass',
          database_host: 'localhost',
          database_port: 5432,
          database_conn_max_age: 10,
          redis_options: {
            webhooks: {
              host: 'redis.example.com',
              port: 6379,
              password: 'redis',
              database: 0,
              default_timeout: 300,
              ssl: true,
            },
            caching: {
              host: 'localhost',
              port: 6379,
              password: 'redis',
              database: 1,
              default_timeout: 300,
              ssl: false,
            },
          },
          email_options: {
            server: 'smtp.example.com',
            port: 587,
            username: 'smtpuser',
            password: 'smtppass',
            timeout: 60,
            from_email: 'netbox@example.com',
          },
          secret_key: 'test-secret-key',
          banner_top: '',
          banner_bottom: '',
          banner_login: '',
          base_path: '/',
          superuser_username: 'testsuperuser',
          superuser_email: 'super@localhost',
        }
      end

      it { is_expected.to compile }
    end
  end
end
