---
layout:     default
title:      Installation Issues
body_id:    docs
created_at: Tue Dec 04 13:20:00 +1030 2007
---

{{ page.title }}
================

If you've followed the [install instructions](/getting-started) but run
into problems, you can find some tips below.

Dependencies
------------

First port of call if you're having issues with an installation is to make sure
you have all the dependencies installed. RubyGems should take care of this for
you, but just in case, make sure you have the following gems as well:

* [addressable][addressable]
* [json_pure][json_pure]
* [RSpec][rspec] - for running specs on DataMapper itself
* [YARD][yard]   - for building documentation

Installing an adapter
---------------------

You will also need to install the adapter for your platform:

{% highlight bash linenos %}
gem install dm-mysql-adapter
{% endhighlight %}

The current database adapters are:

* dm-mysql-adapter
* dm-sqlite-adapter
* dm-postgres-adapter
* dm-oracle-adapter
* dm-sqlserver-adapter

There are also many more database, and non-database, adapters.

Uninstalling all DataMapper gems
--------------------------------

Should you ever have the need to uninstall datamapper completely, Dan Kubb has prepared a bash command that does the trick. Have a look at [this gist](http://gist.github.com/31187) for a oneliner that gets rid of datamapper completely.

Getting Help
------------

If you still have issues, we suggest getting onto the [mailing list](http://groups.google.com/group/datamapper)
or the [IRC channel](irc://irc.freenode.net/%23datamapper) and asking around.
There are friendly people there to help you out.

[addressable]:http://rubygems.org/gems/addressable
[json_pure]:http://rubygems.org/gems/json_pure
[rspec]:http://rubygems.org/gems/rspec
[yard]:http://rubygems.org/gems/yard
