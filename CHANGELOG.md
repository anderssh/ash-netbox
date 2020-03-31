# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] 2020-03-30

* Handle `ADMINS` in the config with the the `admins` array of hashes
* Handle debug option
* Handle enforce_global_unique option
* Handle exempt_view_permissions option
* Handle the metrics_enabled option
* Handle the prefer_ipv4 option
* Add validate command to validate python

## [0.1.0] 2020-03-25

* Initial release.
* Download, install and start Netbox, with optionally also handling PostgreSQL and redis.
* Most important settings can be configured, but plenty are missing.
* Supports EL8 and nothing else right now.