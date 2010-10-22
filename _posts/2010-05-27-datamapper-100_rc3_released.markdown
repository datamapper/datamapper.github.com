---
layout:       articles
categories:   articles
tags:         important
title:        DataMapper 1.0.0 rc3 released
created_at:   2010-05-27T14:57:00-7:00
summary:      Includes several bugs fixes for issues found in rc2, as well as a few other tickets in the queue.
author:       dkubb
---

{{ page.title }}
================

Today I released DataMapper 1.0.0 rc3. It includes several bugs fixes
for issues found in rc2, as well as a few other tickets in the queue.

How do I install rc3?
---------------------

Since the installation process is pretty similar to rc2, I'm going to
give you the abbreviated version. [Click here](http://bit.ly/dC7U1p) if
you would like to see the release notes.

1) Install dm-core:

{% highlight bash %}
$ gem install dm-core --pre
{% endhighlight %}

2) Install an adapter:

{% highlight bash %}
$ gem install dm-sqlite-adapter --pre
{% endhighlight %}

3a) Install supporting gems:

{% highlight bash %}
$ gem install dm-migrations dm-transactions --pre
{% endhighlight %}

3b) OR install a metagem with several well tested supporting gems:

{% highlight bash %}
$ gem install data_mapper --pre
{% endhighlight %}

This pulls a nice base stack for DM development. The gems included are:

* dm-core
* dm-aggregates
* dm-constraints
* dm-migrations
* dm-transactions
* dm-serializer
* dm-timestamps
* dm-validations
* dm-types

Or use this one-liner to install everything in one go:

{% highlight bash %}
$ gem install data_mapper dm-sqlite-adapter --pre
{% endhighlight %}

What's changed?
---------------

To see more information about the tickets we've closed since 0.10.2
check out the [current milestone status](http://bit.ly/b4yVl3) on Lighthouse.

How to report issues
--------------------

Please report any issues you find in IRC, on the mailing list, or in
the tracker:

* [IRC](irc://irc.freenode.net/%23datamapper)
* [Mailing List](http://groups.google.com/group/datamapper)
* [Bug Tracker](http://datamapper.lighthouseapp.com/projects/20609-datamapper)
