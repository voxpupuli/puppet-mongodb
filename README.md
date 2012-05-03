# mongodb puppet module

## Overview

Installs mongodb on Ubuntu/Debian per 10gen [installation documentation](http://www.mongodb.org/display/DOCS/Ubuntu+and+Debian+packages).

## Usage

### class mongodb

Parameters:

* init: optionally specify the init script used, accepts sysv or upstart.

By default ubuntu is upstart and debian uses sysv.

Examples:

    class mongodb {
      init => 'sysv',
    }

## Supported Platforms

The module have been tested on the following operating systems. Testing and patches for other platforms are welcomed.

* Debian Wheezy

This module is under development and does not manage mongodb.conf at the moment.
