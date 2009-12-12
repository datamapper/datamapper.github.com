---
layout:     default
title:      Installation Issues
body_id:    docs
created_at: Tue Dec 04 13:20:00 +1030 2007
---

{{ page.title }}
================

If you've followed the [install instructions](/getting-started.html) but run into
problems, you can find some tips below.

<h2 class="newRelease">Windows Users</h2>

<p class="newRelease" markdown="true">At present, [DataObjects](http://rdoc.info/projects/datamapper/do)
does not run well on Windows natively <br>and will require you to install cygwin
or another linux-like <br>environment. People have been able to get it installed
and running <br>on Windows but with severe drops in performance. This is a known
<br>issue and we're working on it.</p>

Dependencies
------------

First port of call if you're having issues with an installation is to make sure
you have all the dependencies installed. Rubygems should take care of this for
you, but just in case, make sure you have the following gems as well:

* fastthread
* json
* rspec - for running specs on DataMapper itself

Using Master
------------

You will also need to install the DataObject gem and the adapter for your
platform

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
or the [IRC channel](irc://irc.freenode.net/#datamapper) and asking around. There's friendly
people there to help you out.
