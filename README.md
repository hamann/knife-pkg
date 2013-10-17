# Knife::Pkg

## A knife plugin to deal with package updates

[![Build Status](https://travis-ci.org/hamann/knife-pkg.png?branch=master)](https://travis-ci.org/hamann/knife-pkg)

This is a plugin for [Chef's](http://www.opscode.com/chef) [knife](http://docs.opscode.com/knife.html) tool. It allows you to do package updates on your nodes with ease!


## Examples

List all updates:

 - without `chef`

```sh
$ knife pkg show updates "127.0.0.1" -z -x vagrant -P 'vagrant' -m -p 2222
===> 127.0.0.1
	base-files (new: 7.1wheezy2 | installed: 7.1wheezy1)
	curl (new: 7.26.0-1+wheezy4 | installed: 7.26.0-1+wheezy3)
	dmsetup (new: 2:1.02.74-8 | installed: 2:1.02.74-7)
	dpkg (new: 1.16.12 | installed: 1.16.10)
  ...
```

  - with `chef` search

```sh
$ knife pkg show updates "*:*"
===> kpp1.example.com
  accountsservice (new: 0.6.15-2ubuntu9.6.1 | installed: 0.6.15-2ubuntu9.6)
	apparmor (new: 2.7.102-0ubuntu3.9 | installed: 2.7.102-0ubuntu3.7)
	apt (new: 0.8.16~exp12ubuntu10.15 | installed: 0.8.16~exp12ubuntu10.10)
	apt-transport-https (new: 0.8.16~exp12ubuntu10.15 | installed: 0.8.16~exp12ubuntu10.10)
	apt-utils (new: 0.8.16~exp12ubuntu10.15 | installed: 0.8.16~exp12ubuntu10.10)
	apt-xapian-index (new: 0.44ubuntu5.1 | installed: 0.44ubuntu5)
  ...
===> kpp2.example.com
	abrt-libs.x86_64 (new: 2.0.8-16.el6.centos.1 | installed: 2.0.8-15.el6.centos)
	abrt-tui.x86_64 (new: 2.0.8-16.el6.centos.1 | installed: 2.0.8-15.el6.centos)
	bash.x86_64 (new: 4.1.2-15.el6_4 | installed: 4.1.2-14.el6)
	bind-libs.x86_64 (new: 32:9.8.2-0.17.rc1.el6_4.6 | installed: 32:9.8.2-0.17.rc1.el6)
	bind-utils.x86_64 (new: 32:9.8.2-0.17.rc1.el6_4.6 | installed: 32:9.8.2-0.17.rc1.el6)
	busybox.x86_64 (new: 1:1.15.1-16.el6_4 | installed: 1:1.15.1-15.el6)  
  ...
```

  - install updates with user interaction:

```sh
$ knife pkg install updates "chef_environment:beta"
===> beta.example.com
  The following updates are available:
	NetworkManager.x86_64 (new: 1:0.9.8.2-9.git20130709.fc19 | installed: 1:0.9.8.2-2.fc19)
	NetworkManager-glib.x86_64 (new: 1:0.9.8.2-9.git20130709.fc19 | installed: 1:0.9.8.2-2.fc19)
	audit.x86_64 (new: 2.3.2-1.fc19 | installed: 2.3.1-2.fc19)
	audit-libs.x86_64 (new: 2.3.2-1.fc19 | installed: 2.3.1-2.fc19)
  ...
  Do you want to update all packages? [y|n]: n
  Do you want to update audit.x86_64 (2.3.2-1.fc19)? [y|n]: y
  Do you want to update NetworkManager.x86_64 (1:0.9.8.2-9.git20130709.fc19)? [y|n]: y
  Do you want to update ca-certificates.noarch (2013.1.94-1.fc19)? [y|n]: y
  Do you want to update cronie.x86_64 (1.4.10-7.fc19)? [y|n]: n
  ...
===> beta.bar.de
	The following updates are available:
  ...
  tzdata.noarch (new: 2013g-1.fc19 | installed: 2013c-1.fc19)
	util-linux.x86_64 (new: 2.23.2-4.fc19 | installed: 2.23.1-3.fc19)
	vim-minimal.x86_64 (new: 2:7.4.027-2.fc19 | installed: 2:7.3.944-1.fc19)
	wget.x86_64 (new: 1.14-8.fc19 | installed: 1.14-5.fc19)
	yum.noarch (new: 3.4.3-111.fc19 | installed: 3.4.3-99.fc19)
	Do you want to update all packages? [y|n]: y
  updating...
  all packages updated!
```

  - install defined updates without confirmation, ask for all others:

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
===> s6.example.com
===> s7.example.com
	Updating libxml2 (2.7.8.dfsg-2+squeeze7)
===> s8.example.com
	Updating libxml2 (2.7.8.dfsg-2+squeeze7)
...
```

## Supported Packet Managers

* apt
* yum
* *look at [example](https://github.com/hamann/knife-pkg/blob/master/lib/knife-pkg/controllers/debian.rb) and send PRs*

Which packet manager will be used depends on what `ohai` (or `chef`) reports as [`platform_family`](https://github.com/opscode/ohai/blob/master/lib/ohai/plugins/linux/platform.rb#L103) for a node. So it should work if your node is of type 'debian' (=> apt), 'fedora' or 'rhel' (=> yum)


## Requirements

* SSH access
* Chef(-Server) or anything else which supports `search(:node, "*:*")` (*not required when you use `-m`*)
* when `-m` option is given, `ohai` has to be installed on the node  ( sudo gem install ohai --no-ri --no-rdoc )


## Installation

Add this line to your application's Gemfile:

    gem 'knife-pkg'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install knife-pkg
    

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
