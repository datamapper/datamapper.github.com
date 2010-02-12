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

Using Master
------------

You will also need to install the DataObject gem and the adapter for your
platform:

{% highlight bash linenos %}
sudo gem install data_objects
sudo gem install do_mysql
{% endhighlight %}

The current database adapters are:

* do_mysql
* do_sqlite3
* do_postgres

Getting Help
------------

If you still have issues, we suggest getting onto the [mailing list](http://groups.google.com/group/datamapper)
or the [IRC channel](irc://irc.freenode.net/#datamapper) and asking around.
There are friendly people there to help you out.

[addressable]:http://gemcutter.org/gems/addressable
[json_pure]:http://gemcutter.org/gems/json_pure
[rspec]:http://gemcutter.org/gems/rspec
[yard]:http://gemcutter.org/gems/yard


