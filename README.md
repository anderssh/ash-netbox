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

This module installs and configures Netbox. Netbox needs PostgreSQL and Redis to work, and this module can optionally handle that too.

### Setup Requirements 

You need to have epel configured. The easiest way to do that is by running:

```bash
yum install -y epel-release
```

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

The following code shows an example where you have a profile::netbox (because of course you are using the "roles and profiles" design) which takes in the secret key. This could for example be stored in Hiera eyaml

```puppet
class profile::netbox (
  String $netbox_secret_key,
) {

# setsebool  httpd_can_network_connect 1
# usermod apache -G netbox

  class { 'netbox':
    secret_key    => $netbox_secret_key,
  }
```

## Reference

This section is deprecated. Instead, add reference information to your code as Puppet Strings comments, and then use Strings to generate a REFERENCE.md in your module. For details on how to add code comments and generate documentation with Strings, see the Puppet Strings [documentation](https://puppet.com/docs/puppet/latest/puppet_strings.html) and [style guide](https://puppet.com/docs/puppet/latest/puppet_strings_style.html)

If you aren't ready to use Strings yet, manually create a REFERENCE.md in the root of your module directory and list out each of your module's classes, defined types, facts, functions, Puppet tasks, task plans, and resource types and providers, along with the parameters for each.

For each element (class, defined type, function, and so on), list:

  * The data type, if applicable.
  * A description of what the element does.
  * Valid values, if the data type doesn't make it obvious.
  * Default value, if any.

For example:

```
### `pet::cat`

#### Parameters

##### `meow`

Enables vocalization in your cat. Valid options: 'string'.

Default: 'medium-loud'.
```

## Limitations

In the Limitations section, list any incompatibilities, known issues, or other warnings.

## Development

In the Development section, tell other users the ground rules for contributing to your project and how they should submit their work.

## Release Notes/Contributors/Etc. **Optional**

If you aren't using changelog, put your release notes here (though you should consider using changelog). You can also add any additional sections you feel are necessary or important to include here. Please use the `## ` header.
