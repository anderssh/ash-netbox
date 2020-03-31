require 'spec_helper'

describe 'netbox::config' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          user: 'testuser',
          group: 'testgroup',
          install_root: '/opt',
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
          admins: [
            {
              name: 'Name Nameson',
              email: 'nameson@example.com'
            },
            {
              name: 'Another Guy',
              email: 'guy@example.com'
            },
          ],
          debug: false,
          enforce_global_unique: false,
          login_required: false,
          metrics_enabled: false,
          prefer_ipv4: false,
          exempt_view_permissions: [],
          napalm_username: 'some_username',
          napalm_password: 'some_secret_password',
          napalm_timeout: 30,
        }
      end
      it { is_expected.to compile }
    end
  end
end
