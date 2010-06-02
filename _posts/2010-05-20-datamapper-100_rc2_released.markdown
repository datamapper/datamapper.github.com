---
layout:       articles
categories:   articles
tags:         important
title:        DataMapper 1.0.0 rc2 released
created_at:   2010-05-20T14:30:00-7:00
summary:      We are starting a public RC process now to make sure the installation process is solid and that the API is stable before 1.0 is released at RailsConf.
author:       dkubb
---

{{ page.title }}
================

I just wanted to give you the heads up that we've just released
DataMapper 1.0.0 rc2.

With RailsConf coming up, and the launch of DM 1.0, we are starting
the RC process now to make sure the installation process is solid and
that the API is stable beforehand.

Installation Changes
--------------------

The installation process for DM 1.0 is pretty similar to what it was
previously in 0.10.x and 0.9.x with a few exceptions:

1. Using auto-migration and auto-upgrading require dm-migrations
rather than just dm-core. The reason for this is that dm-migrations
*should* share alot of code with auto-migrations, but they don't, and
in an attempt to DRY things up we've centralized all the code in one
package and will begin refactoring the code over the coming months.

2. Transactions require the use of the dm-transactions gem.

3. It is no longer necessary to gem install data_objects or any do_*
gem directly. Each DO based adapter has been extracted into their own
gems, and installing them will setup the dependencies on dm-core and
the appropriate DO gem(s). The new adapters are:
  * dm-sqlite-adapter
  * dm-postgres-adaper
  * dm-mysql-adapter
  * dm-oracle-adapter
  * dm-sqlserver-adapter

How do I install the RC?
------------------------

The first step is to make sure you've installed extlib 0.9.15:

{% highlight bash %}
$ gem install extlib -v0.9.15
{% endhighlight %}

Note that this will go away in the next RC. I forgot to add extlib
0.9.15 as a dependency for rc2, which is why it's required explicitly
at the moment.

Since this is a prerelease gem you have to install dm-core with the --
pre option, eg:

{% highlight bash %}
$ gem install dm-core --pre
{% endhighlight %}

If you don't specify --pre, rubygems will download the last stable
version of DM, which is 0.10.2.

The next thing you want to do is decide which adapter you want to use.
For example if you want to use sqlite, do:

{% highlight bash %}
$ gem install dm-sqlite-adapter --pre
{% endhighlight %}

This should pull in data_objects and do_sqlite3 automatically, so no
need to specify either of those explicitly anymore.

It's likely you'll want to use migrations (for classic or auto-
migrations), and transactions when using sqlite, so to install them
do:

{% highlight bash %}
$ gem install dm-migrations dm-transactions --pre
{% endhighlight %}

There is also a metagem which combines several gems into a single
package:

{% highlight bash %}
$ gem install data_mapper --pre
{% endhighlight %}

This pulls a nice base stack for DM development. The gems included
are:

* [dm-core](http://github.com/datamapper/dm-core)
* [dm-aggregates](http://github.com/datamapper/dm-aggregates)
* [dm-constraints](http://github.com/datamapper/dm-constraints)
* [dm-migrations](http://github.com/datamapper/dm-migrations)
* [dm-transactions](http://github.com/datamapper/dm-transactions)
* [dm-serializer](http://github.com/datamapper/dm-serializer)
* [dm-timestamps](http://github.com/datamapper/dm-timestamps)
* [dm-validations](http://github.com/datamapper/dm-validations)
* [dm-types](http://github.com/datamapper/dm-types)

So putting this all together you can do:

{% highlight bash %}
$ gem install extlib -v0.9.15
$ gem install data_mapper dm-sqlite-adapter --pre
{% endhighlight %}

Again, the extlib installation step will not be necessary in the next
RC.

What are the changes?
---------------------

There are alot of internal refactorings, some bug fixes, but for the
most part 1.0.0 should be quite similar to 0.10.2. We decided to
launch 1.0 because DM has been in a relatively stable state for the
last 6 months, and there aren't any really major API changes left.
Anything that's planned are more additions rather than changes to
existing functionality, so we decided it was better to freeze the
current API at 1.0 and release for RailsConf.

There are some simplifications in the Property/Type API you should be
aware of. Some custom types you have may require slight modifications
to work with 1.0.0 rc2. Piotr Solnica will be posting some information
about how to do the modification, but for now look at the Property
subclasses in dm-types as well as inside dm-core to get an idea of how
it works.

As mentioned, the other large change is how auto-migrations have been
moved to dm-migrations, as well as transactions to dm-transactions.
The main reason we moved those from the core is that only a small
fraction of DM adapters support migrations and transactions, and it
didn't seem right for the core layer to know anything about those
concerns. I felt that having them in a separate package allows us to
eliminate some duplcation (in the case of migrations), and ensure
transactions gets more attention than if it was part of core.

Where was rc1?
--------------

You might be asking yourself "where was rc1?". Well... I decided to do
a soft launch of the first rc and just announce it to people in the
[#datamapper](irc://irc.freenode.net/#datamapper) IRC channel on freenode. It's been a few months since we
did any kind of release, and with the new gem organization I wasn't
sure if we'd have all the kinks worked out. There was one small issue
actually, so we bumped to rc2 and released the same day. We also added
the latest DO as a dependency, which has a number of improvements/bug
fixes, so I think this was a good thing overall.

How to report issues
--------------------

Please report any issues you find in IRC, on the mailing list, or in
the tracker:

* [IRC](irc://irc.freenode.net/#datamapper)
* [Mailing List](http://groups.google.com/group/datamapper)
* [Bug Tracker](http://datamapper.lighthouseapp.com/projects/20609-datamapper)
