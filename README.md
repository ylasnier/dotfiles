# dotfiles ~/.*

My very personal setup for *nix systems.

## Introduction

This dotfiles repository is meant to setup almost my whole environment on a new
machine in just a few command lines.

It does not only include my settings files, but also scripts to install
all applications I use on each operating systems.

## Prequesites

`curl` and `git` are required.

`ruby` and `Xcode` are also required on OS X (installing just the `Xcode Command Line Tools` is not sufficient).

The Linux installation script works in fact only for Debian family
distributions (it uses `aptitude`). For complete packages installation under
Debian, user has to be `root`or a `sudoer`.

## Installation

### Complete setup

The entire process can be done automatically with :

```bash
curl https://raw.githubusercontent.com/ylasnier/dotfiles/master/bootstrap.sh | sh
```

In this way, the repository will be cloned in the $HOME/.dotfiles directory.
You can also specify a destination in argument :

```bash
curl https://raw.githubusercontent.com/ylasnier/dotfiles/master/bootstrap.sh | sh -s /your/dest/path
```

All applications specified for the running OS will be installed and symbolic
links to each dotfiles will be created in the home directory.

### Step-by-step

#### Clone the repository

```bash
git clone --recursive http://github.ansamb.com/yves/dotfiles.git
cd dotfiles
```

#### Links

```bash
./install -c linux/install.conf.yaml  # or osx/install.conf.yaml
./install -c common/install.conf.yaml
```

#### Packages

##### Debian

```bash
sudo ./linux/install-packages
./common/install-packages
```

##### OS X

```bash
./osx/install-packages
./common/install-packages
```

## How it works

Dotfiles bootstrapping are powered by [anishathalye/dotbot][dotbot].  Dotbot
create symlinks to dotfiles regarding configuration files. For dotfiles that
are common to Linux and OS X, checkout [common/install.conf.yaml][common-conf].
For dotfiles and dotbot configuration specific to each system, checkout
[linux/install.conf.yaml][linux-conf] or [osx/install.conf.yaml][osx-conf]
directories.

Applications installation for each system are just simple scripts I wrote
specifically to each package managers I use (checkout
[linux/install-packages][linux-packages] for `aptitude`,
[osx/install-packages][osx-packages] for `brew`, and
[common/install-packages][common-packages] for any package involving other
common ways of installation, such as `npm` packages).

## Maintenance

As I think dotfiles are very personal, I designed this dotfiles to correspond to my
very own configuration and I will maintain it regarding my needs.

But hey, it's open source ! Feel free to take as much inspirations as you want
and to re-use it at your convenience.

## License

Copyright (c) 2015 Yves Lasnier. Released under the MIT License.
See [LICENSE.md][license] for details.

[dotbot]: https://github.com/anishathalye/dotbot/
[common-dir]: common
[linux-dir]: linux
[osx-dir]: osx
[common-conf]: common/install.conf.yaml
[linux-conf]: linux/install.conf.yaml
[osx-conf]: osx/install.conf.yaml
[common-packages]: common/install-packages
[linux-packages]: linux/install-packages
[osx-packages]: osx/install-packages
[license]: LICENSE.md

