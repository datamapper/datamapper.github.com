---
layout:       articles
categories:   articles
title:        Living On The Edge Of DataMapper
created_at:   2009-11-27T19:04:34-05:00
summary:      rubygems, git and github will get you going
author:       snusnu
---

{{ page.title }}
================

DataMapper is organized into multiple gems that reside within 3 `git` repositories.
At the very least you will need to clone the [extlib](http://github.com/datamapper/extlib)
and [dm-core](http://github.com/datamapper/dm-core) gems. If you plan to develop with a
relational database, you will also need to install [do](http://github.com/datamapper/do).
The [dm-more](http://github.com/datamapper/dm-more) project contains further optional
gems that will make developing applications with DataMapper even easier.


### Step 0 - Prerequisites

First, a couple of basic requirements before we begin. You will need to have
an up-to-date installation of [rubygems](http://www.rubygems.org/), the [ruby](http://www.ruby-lang.org/)
package management system. To check what version you have, issue the following command:

{% highlight bash %}
gem --version
{% endhighlight %}

If that doesn't give at least version 1.3.5, update your [rubygems](http://www.rubygems.org/)
installation by running:

{% highlight bash %}
sudo gem update --system
{% endhighlight %}

Next, you'll need `git`. It's the source code management tool DataMapper uses.
Its installation is left up to the reader, but here's a few good resources to go
to for help:

* [Git - Fast Version Control System](http://git-scm.com/) - Homepage
* [Installing GIT on MAC OSX 10.5 Leopard](http://dysinger.net/2007/12/30/installing-git-on-mac-os-x-105-leopard/)
* [Git On Windows](http://ropiku.wordpress.com/2007/12/28/git-on-windows/)
* [Installing Git on Ubuntu](http://chrisolsen.org/2008/03/10/installing-git-on-ubuntu/)


### Step 1 - Gem dependencies

Once you have `rubygems` and `git` installed, you'll need a few gems that `datamapper` depends on.
To install them, run the following commands. Note that depending on your setup, you will possibly have
to prepend `sudo` to some of the following commands (this applies to all the commands in this article).

{% highlight bash %}
gem install gemcutter
gem tumble
gem install rake rspec jeweler addressable
{% endhighlight %}


### Step 2 - Install dm-core

Now that you have everything you need in place, it's time to install the
[extlib](http://github.com/datamapper/extlib) and [dm-core](http://github.com/datamapper/dm-core)
gems. To do that, prepare a directory where you will keep the sources, clone
the `git` repositories, and install the contained gems with the provided `rake` tasks.

Prepare a directory where you will keep the `git` clones

{% highlight bash %}
mkdir -p ~/src/github/vendor
{% endhighlight %}

Change into that directory, clone the repositories and install the gems
with the provided rake task.

{% highlight bash %}
cd ~/src/github/vendor
git clone git://github.com/datamapper/extlib.git
git clone git://github.com/datamapper/dm-core.git
cd extlib/
rake install
cd ..
cd dm-core/
rake install
{% endhighlight %}

### Step 3 - Install do and dm-more (Optional)

With [dm-core](http://github.com/datamapper/dm-core) properly installed, you're ready
to install [do](http://github.com/datamapper/do) and [dm-more](http://github.com/datamapper/dm-more).
The `do` project provides support for various relational databases and `dm-more` contains various gems
that help you with common tasks you will face when developing database backed applications.

Installing a `do` adapter requires you to install `data_objects` as a minimum requirement.
Additionally, you will need to install one or more specific database adapters that are provided within
the project. The following shows you how to install `data_objects` and the `do_mysql` adapter. Replace
`do_mysql` with whatever provided database adapter you need to work with.

{% highlight bash %}
cd ~/src/github/vendor
git clone git://github.com/datamapper/do.git
cd do/data_objects
rake install
cd ..
cd do_mysql
rake install
{% endhighlight %}

The [dm-more](http://github.com/datamapper/dm-more) project provides various gems that help you with
common database development tasks. Clone the `git` repository, `cd` into the subdirectories that contain
the gems you want to use, and `rake install` them from there. There is also a `rake install` task at the
`dm-more` root directory which installs all of `dm-more's` gems. Unless you help with developing `dm-more`
itself, you probably shouldn't need to install all the gems that `dm-more` provides. The following
instructions show how to clone the `dm-more` project and install the `dm-validations` gem.

{% highlight bash %}
cd ~/src/github/vendor
git clone git://github.com/datamapper/dm-more.git
cd dm-more/dm-validations
rake install
{% endhighlight %}

### Keeping up with changes

Changes happen to DataMapper and it's buddies all the time. To refresh your
installation issue the following commands:

{% highlight bash %}
cd ~/src/github/vendor
cd extlib
git pull origin master
rake install
cd ../dm-core
git pull origin master
rake install
cd ../do
git pull origin master
cd data_objects
rake install
# cd into the desired adapter subdirectory and rake install from there
cd ../dm-more
git pull origin master
# cd into the desired gem subdirectory and rake install from there
{% endhighlight %}

### Uninstall dm-core and friends

Should you ever have the need to uninstall datamapper completely, Dan Kubb has prepared a
bash command that does the trick. Have a look at [this gist](http://gist.github.com/31187)
for a oneliner that gets rid of datamapper completely.
