# Knife::Pkg

## A knife plugin to deal with package updates

[![Build Status](https://travis-ci.org/hamann/knife-pkg.png?branch=master)](https://travis-ci.org/hamann/knife-pkg)

This is a plugin for [Chef's](http://www.opscode.com/chef) [knife](http://docs.opscode.com/knife.html) tool. It allows you to do package updates on your nodes with ease!


## Examples

List all updates:

```sh
$ knife pkg show updates "*:*"
===> kpp1.example.com
	 libxml2 (2.7.8.dfsg-2+squeeze7)
	 postgresql-client-9.2 (9.2.4-2.pgdg60+1)
	 gpgv (1.4.10-4+squeeze2)
	 gnupg (1.4.10-4+squeeze2)
===> kpp2.example.com
	 libxml2 (2.7.8.dfsg-2+squeeze7)
	 postgresql-client-9.2 (9.2.4-2.pgdg60+1)
	 gpgv (1.4.10-4+squeeze2)
	 gnupg (1.4.10-4+squeeze2)
...
```

Install updates with user interaction:

```sh
$ knife pkg install updates "chef_environment:beta"
===> beta.example.com
	The following updates are available:
	libxml2 (2.7.8.dfsg-2+squeeze7)
	libxml2-dev (2.7.8.dfsg-2+squeeze7)
	Should I update all packages? [y|n]: n
	Should I update libxml2 (2.7.8.dfsg-2+squeeze7)? [y|n]: y
	libxml2 (2.7.8.dfsg-2+squeeze7) updated!
	Should I update libxml2-dev (2.7.8.dfsg-2+squeeze7)? [y|n]: y
	libxml2-dev (2.7.8.dfsg-2+squeeze7) updated!
===> beta.bar.de
	The following updates are available:
	libxml2 (2.7.8.dfsg-2+squeeze7)
	libxml2-dev (2.7.8.dfsg-2+squeeze7)
	Should I update all packages? [y|n]: y
	Updating...
	all packages updated!
...
```

Install defined updates without confirmation, ask for all others:

```sh
$ knife pkg install updates "roles:webserver" -U "libxml2,gpgv,gnupg"
===> s1.example.com
===> s2.example.com
===> s3.example.com
	Updating libxml2 (2.7.8.dfsg-2+squeeze7)
	Updating gpgv (1.4.10-4+squeeze2)
	Updating gnupg (1.4.10-4+squeeze2)
===> s4.example.com
	Updating libxml2 (2.7.8.dfsg-2+squeeze7)
	The following updates are available:
	libxml2-dev (2.7.8.dfsg-2+squeeze7)
	Should I update all packages? [y|n]: y
	Updating...
	all packages updated!
===> s5.example.com
	Updating libxml2 (2.7.8.dfsg-2+squeeze7)
	Updating gpgv (1.4.10-4+squeeze2)
	Updating gnupg (1.4.10-4+squeeze2)
===> s6.example.com
	Updating libxml2 (2.7.8.dfsg-2+squeeze7)
===> staging.fuchstreff.de
===> postgres-staging.sauspiel.de
===> s7.example.com
	Updating libxml2 (2.7.8.dfsg-2+squeeze7)
===> s8.example.com
	Updating libxml2 (2.7.8.dfsg-2+squeeze7)
...
```

## Requirements

* SSH access
* Chef(-Server) or anything else which supports `search(:node, "*:*")` (*not required when you use `-m`*)
* when `-m` option is given, `ohai` has to be installed on the node 


## Installation

Add this line to your application's Gemfile:

    gem 'knife-pkg'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install knife-pkg
    

## Supported Platforms

* Debian/Ubuntu
* Centos
* *look at [example](https://github.com/hamann/knife-pkg/blob/master/lib/knife-pkg/controllers/debian.rb) and send PRs*
  

## Overview

The plugin inherits from `Knife::Ssh`, so almost all options and configuration settings are supported.


The following sub-commands are provided:

```
knife pkg show updates SEARCH (options)
```

```
knife pkg install updates SEARCH (options)
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License and Authors

Authors: Holger Amann holger@fehu.org

Licensed under Apache License, Version 2.0 
http://www.apache.org/licenses/LICENSE-2.0
