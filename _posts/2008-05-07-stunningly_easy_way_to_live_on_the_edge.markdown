---
layout:       articles
categories:   articles
title:        The Stunningly Easy Way to Live On The Edge Of DataMapper
created_at:   2008-05-07T19:04:34-05:00
summary:      A little sake goes a long way
author:       afrench
---

{{ page.title }}
================

DataMapper is organized into sub-projects, much like
[Merb](http://www.merbivore.com), and that tends to confuse even the people
working on it....until recently. Michael Ivey, an active contributer to the Merb
project, and our very own Dan Kubb have collaborated on a set of Sake tasks to
help automate and streamline checking out, packaging, installing, uninstalling,
updating, repackaging, and reinstalling the DataMapper and Merb projects.

If you like to live life on the edge, this is the happiest way to do it.

### Step 0 - The Setup

A couple of very basic requirements before we begin. First, you'll need to have
an up-to-date installation of [Rubygems](http://www.rubygems.org/), the Ruby
package management system. To check what version you have do:

{% highlight bash linenos %}
gem --version
{% endhighlight %}

If you aren't on 1.2.x, update by running

{% highlight bash linenos %}
sudo gem update --system
{% endhighlight %}

Next, you'll need `git`. It's the source code management tool DataMapper uses.
Its installation is left up to the reader, but here's a few good resources to go
to for help:

* [Git - Fast Version Control System](http://git.or.cz/) - Homepage
* [Installing GIT on MAC OSX 10.5 Leopard](http://dysinger.net/2007/12/30/installing-git-on-mac-os-x-105-leopard/)
* [Git On Windows](http://ropiku.wordpress.com/2007/12/28/git-on-windows/)
* [Installing Git on Ubuntu](http://chrisolsen.org/2008/03/10/installing-git-on-ubuntu/)

After that, you'll need to `gem uninstall` any of the "dm-\*" projects you
already have installed. This includes 'data_objects' and its associated
adapters.

Next, you'll need a few of the base dependencies.  To install them, run

{% highlight bash %}
sudo gem install addressable english rspec
{% endhighlight %}

Once that's done, do the following:

{% highlight bash linenos %}
mkdir -p ~/src
cd ~/src
{% endhighlight %}

### Step 1 - Have Some Sake

No, not the wonderful alcoholic beverage, the
[system-wide rake tasks library](http://errtheblog.com/posts/60-sake-bomb) by
[PJ Hyett and Chris Wanstrath of Err. The Blog](http://errtheblog.com/).
Ivey's and dkubb's automated
installation and reinstallation scripts are written as sake tasks, so you'll
need it installed on your machine.

{% highlight bash linenos %}
sudo gem install sake
{% endhighlight %}

Once you're done, you should be able to see sake in your path by executing
`which sake` and see where `gem` installed it.

### Step 2 - Install the Tasks

Now that you're all setup with sake and the `src` directory, it's time to
install the sake tasks. They can be found at <http://github.com/dkubb/dm-dev/>
and are very easily installed by doing:

{% highlight bash linenos %}
sake -i http://github.com/dkubb/dm-dev/raw/master/dm-dev.sake
{% endhighlight %}

The tasks that get installed are available for perusal by issuing `sake -T`

{% highlight bash %}
$ sake -T
sake dm:clone                          # Clone a copy of the DataMapper repository and dependencies
sake dm:gems:refresh                   # Pull fresh copies of DataMapper and refresh all the gems
sake dm:gems:wipe                      # Uninstall all RubyGems related to DataMapper
sake dm:install                        # Install dm-core, dm-more and do
sake dm:install:core                   # Install dm-core
sake dm:install:do                     # Install do drivers
sake dm:install:do:data_objects        # Install data_objects
sake dm:install:do:mysql               # Install do_mysql
sake dm:install:do:postgres            # Install do_postgres
sake dm:install:do:sqlite3             # Install do_sqlite3
sake dm:install:more                   # Install dm-more
sake dm:install:more:merb_datamapper   # Install merb_datamapper
sake dm:sake:refresh                   # Remove and reinstall DataMapper sake recipes
sake dm:update                         # Update your local DataMapper.  Run from inside the top-level dm dir
{% endhighlight %}

### Step 3 - Live a little

Change directories into the `src` directory and run `sake dm:clone`. You'll see
git cloning DataMapper Core, DataMapper More, and DataObjects from their
respective repositories on GitHub. When that's done, `cd dm` and have a look
around.

When your ready, return to `~/src/dm` and issue `sake dm:install`.

### All Together Now

When executed together, these 3 steps amount to 7 lines at the command line.
Talk about stunningly easy.

{% highlight bash linenos %}
mkdir -p ~/src
cd ~/src
sudo gem install sake
sake -i http://github.com/dkubb/dm-dev/raw/master/dm-dev.sake
sake dm:clone
cd dm
sake dm:install
{% endhighlight %}

Changes happen to DataMapper and it's buddies all the time. To refresh your
installation of DataMapper and DataObjects, return to `~/src/dm` and issue:

{% highlight bash linenos %}
sake dm:gems:refresh
{% endhighlight %}

It will uninstall your local gems, pull down fresh changes from github, and
reinstall the gems again.

On a side note, checkout <http://merbivore.com/merb-dev.sake> for the original
merb related sake tasks by Michael Ivey wrote that these came from.
