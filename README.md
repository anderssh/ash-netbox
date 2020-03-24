# netbox

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with netbox](#setup)
    * [What netbox affects](#what-netbox-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with netbox](#beginning-with-netbox)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

Puppet module for installing and configuring Netbox, an IPAM (IP Adress Management) tool initially conceived by the network engineering team at DigitalOcean. [The documentation for Netbox can be found here](https://netbox.readthedocs.io/) 

## Setup

### What netbox affects

This module installs and configures Netbox. Netbox needs PostgreSQL and Redis to work, and this module can optionally handle that too. Netbox is a Python web applications built on the Django framework and uses the Gunicorn webserver. Usually you place a webserver (like Nginx og Apache) in front of it. This is not part of this module, but a configuration using Apache is provided. Everything in this module is made according to the [Netbox documentation](https://netbox.readthedocs.io/).

### Setup Requirements 

You need to have epel configured. The easiest way to do that is by running:

```bash
yum install -y epel-release
```

This module has been tested with Apache HTTPD using the `puppetlabs-apache` module. There are a couple of gotchas, [see example with Apache on Centos/RHEL8](#example-with-apache-on-centosrhel8).

### Beginning with Netbox

Add dependency modules to your puppet environment:

* camptocamp/systemd
* puppet/archive
* puppetlabs/inifile
* puppetlabs/stdlib

If you ar going to use this module to install PostgreSQL and Redis, then you need these as well:

* puppetlabs/postgresql
* puppetlabs/concat
* puppet/redis

## Usage

In its simplest configuration, the module needs only one parameter set. This is the `secret_key`. This is something Netbox will not run without, and is recomended to be an at least 50 character long string of letters, symbols and numbers. This is to be treated as a secret.

If you have installed Netbox in an non-default location, then you have adapt the above description accordingly. 

By default, PostgreSQL and Redis is set up as part of the installation. If you have your own PostgreSQL or Redis installation you want to use, you simply set `$handle_database` and `$handle_redis` to `false`. Some configuration is offered, but if you need to tweek any of those two softwares, I would recommend handling them outside of this module.

The following code shows an example where you have a profile::netbox (because of course you are using the "roles and profiles" design pattern) which takes in the secret key. This could for example be stored in Hiera eyaml.

```puppet
class profile::netbox (
  String $netbox_secret_key,
) {

  class { 'netbox':
    secret_key    => $netbox_secret_key,
  }
```

You also _need_ to set up a django superuser manually after installing. This is the admin account to your Netbox application. To do this, use the virtual Python environment created by the installation and the `manage.py` command:

```
# cd /opt/netbox
# source venv/bin/activate
(venv) # cd netbox
(venv) # python3 manage.py createsuperuser
Username: admin
Email address: admin@example.com
Password:
Password (again):
Superuser created successfully.
```

### A more interesting example

You probably want to adjust your parameters a little more than the minimal example. Here is a more realistic one:

```puppet

  class { 'netbox':
    secret_key    => $netbox_secret_key,
    allowed_hosts => [$trusted[certname], 'localhost'],
    banner_top    =>  'TOP BANNER TEXT',
    banner_login  => 'WELCOME TO THE NETBOX LOGIN',
    banner_bottom =>  'BOTTOM BANNER TEXT',
    database_password => $netbox_database_password,
    String $email_from_email = "netbox@${trusted[domain]},
  }
```

The `$netbox_database_password is expected to be defined in wherever you include the Netbox module from. Should probably be stored in Hiera Eyaml.

### Example with Apache on Centos/RHEL8

Here is a full working example with a Netbox profile which includes Netbox module and Apache with settings as recommended in the Netbox documentation. Note that for this setup to work you need:

* The boolean `httpd_can_network_connect` set to true:
  - `setsebool httpd_can_network_connect 1 -P`
* The `apache` user must be part of the `netbox`group:
  - `usermod apache -G netbox`
You can of course fix this with Puppet. 

```puppet

# Netbox
#
# Profile for running Netbox through the ahs/netbox-module
#
class profile::netbox (
  String $netbox_secret_key,
) {

# setsebool  httpd_can_network_connect 1
# usermod apache -G netbox

  class { 'netbox':
    secret_key    => $netbox_secret_key,
    allowed_hosts => [$trusted[certname]],
    banner_top    =>  'TOP BANNER TEXT',
    banner_bottom =>  'BOTTOM BANNER TEXT',
  }
  class { 'apache':
    default_vhost => false,
  }

  class { 'apache::mod::wsgi':
    mod_path     => '/usr/lib64/httpd/modules/mod_wsgi_python3.so',
    package_name => 'python3-mod_wsgi',
  }

  apache::vhost { $trusted[certname]:
    servername              => $trusted[certname],
    port                    => '80',
    proxy_preserve_host     => true,
    docroot                 => '/opt/netbox/netbox/',
    request_headers         => [
      'set "X-Forwarded-Proto" expr=%{REQUEST_SCHEME}',
    ],
    proxy_pass              => [
      { path        => '/',
        url         => 'http://127.0.0.1:8001/',
        reverse_url => 'http://127.0.0.1:8001/'
      },
    ],
    aliases                 => [
      { alias => '/static',
        path  => '/opt/netbox/netbox/static',
      },
    ],
    wsgi_pass_authorization => 'On',
    directories             => [
    { path            => '/opt/netbox/netbox/static',
      provider        => 'directory',
      custom_fragment => 'Options Indexes FollowSymLinks MultiViews'
    },
    { path            => '/static',
      provider        => 'location',
      custom_fragment => 'ProxyPass !'
    },
  ],
  }
}
```

## Limitations

In the Limitations section, list any incompatibilities, known issues, or other warnings.

## Development

In the Development section, tell other users the ground rules for contributing to your project and how they should submit their work.

## Release Notes/Contributors/Etc. **Optional**

If you aren't using changelog, put your release notes here (though you should consider using changelog). You can also add any additional sections you feel are necessary or important to include here. Please use the `## ` header.
