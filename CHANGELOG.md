# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.1] 2020-05-26
* Bugfix, some `VIRTUAL_ENV`s were hard coded. Use the `$venv_dir` variable instead

## [1.1.0] 2020-05-07

* Don't enforce creation and letting netbox own `$install_root`
* Change description of `$install_root`
* Clean up code
* Add correct documentation of the `$metrics_enabled` parameter

## [1.0.1] 2020-04-29

* Bugfix, there was a rouge space in `allowed_hosts` in the config template.

## [1.0.0] 2020-04-08

* Add support for all the date and time parameters
* Use version 2.7.11 as default. 
* Add more in the limitations section
* First major version
* Formatting, pdk updates, structuring


## [0.2.1] 2020-03-31

* Handle `ADMINS` in the config with the the `admins` array of hashes
* Handle debug option
* Handle enforce_global_unique option
* Handle exempt_view_permissions option
* Handle the metrics_enabled option
* Handle the prefer_ipv4 option
* Add validate command to validate python
* Add Napalm support (no Napalm arguments yet)
* Add possibility to download django-storage. Can not be configured yet
* Add way to install Netbox with this module without access internet.

## [0.1.0] 2020-03-25

* Initial release.
* Download, install and start Netbox, with optionally also handling PostgreSQL and redis.
* Most important settings can be configured, but plenty are missing.
* Supports EL8 and nothing else right now.