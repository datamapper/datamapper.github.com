---
layout:       articles
categories:   articles
tags:         important
title:        DataMapper 1.0.2 released
created_at:   2010-09-07T18:59:47 -0700
summary:      DataMapper 1.0.2 is here!
author:       dkubb
---

{{ page.title }}
================

I'm pleased to announce that we released DataMapper 1.0.2 this afternoon.

This fixes a few small bugs discovered since the 1.0.0 release.

Earlier today I shipped 1.0.1, but there were some bugs discovered in the docs that caused rdoc and YARD to output some really nasty looking warnings. Rather than just telling people to ignore them, I decided to work-around the problems as much as I could. Even still, I'm going to recommend that you use --no-ri --no-rdoc to install the gems because some of the errors are inside YARD and rdoc themselves, and the authors need time to fix the bugs that I can't work around.

Installation
------------

Install dm-core:

`$ gem install dm-core --no-ri --no-rdoc`

The next thing you want to do is decide which adapter you want to use. For example if you want to use sqlite, do:

`$ gem install dm-sqlite-adapter --no-ri --no-rdoc`

It's likely you'll want to use migrations (for classic or auto-migrations), and transactions when using sqlite, so to install them do:

`$ gem install dm-migrations dm-transactions --no-ri --no-rdoc`

There is also a metagem which combines several gems into a single package:

`$ gem install data_mapper --no-ri --no-rdoc`

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

So putting this all together you can do:

`$ gem install data_mapper dm-sqlite-adapter --no-ri --no-rdoc`

Changes
-------

Here's a list of the tickets we've resolved since 1.0.0:

[http://datamapper.lighthouseapp.com/projects/20609/milestones/75769](http://datamapper.lighthouseapp.com/projects/20609/milestones/75769)

How to report issues
--------------------

Please report any issues you find in IRC, on the mailing list, or inthe tracker:

* [IRC](irc://irc.freenode.net/%23datamapper)
* [Mailing List](http://groups.google.com/group/datamapper)
* [Bug Tracker](http://datamapper.lighthouseapp.com/projects/20609-datamapper)
