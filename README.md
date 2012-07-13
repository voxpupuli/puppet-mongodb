# mongodb puppet module

## Overview

Installs mongodb on Ubuntu/Debian per 10gen [installation documentation](http://www.mongodb.org/display/DOCS/Ubuntu+and+Debian+packages).

## Usage

### class mongodb

Parameters:
* enable_10gen (default: false) - Whether or not to set up 10gen software repositories
* init (auto discovered) - override init (sysv or upstart) for Debian derivitives
* location - override apt location configuration.
* packagename (auto discovered) - override the package name (eg: for EPEL)
* servicename (auto discovered) - override the service name

By default ubuntu is upstart and debian uses sysv.

Examples:

    class mongodb {
      init => 'sysv',
    }

## Supported Platforms

* Debian Wheezy
* Ubuntu 12.04 (precise)
* RHEL 6
