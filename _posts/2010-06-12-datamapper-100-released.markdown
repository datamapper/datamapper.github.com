---
layout:       articles
categories:   articles
tags:         important
title:        DataMapper 1.0 released
created_at:   2010-05-27T14:57:00-7:00
summary:      DataMapper 1.0 is here! There are changes to be aware of so please, read on.
author:       knowtheory
---

{{ page.title }}
================

[DataMapper 1.0 (Vermouth)](http://github.com/datamapper/dm-core/tree/v1.0.0) was released earlier this week, coinciding with [Dirkjan Bussink](http://twitter.com/dbussink)'s [presentation at Railsconf 2010](http://en.oreilly.com/rails2010/public/schedule/detail/14198) ([his slides are posted](http://www.slideshare.net/dbussink/datamapper-railsconf2010) as well).

The transition from the 0.10.x series to 1.0 does involve several changes regarding how users will interact with DataMapper.  Unfortunately we have no had time to update all of our documentation on the site, so please bear with us while we get everything in order.  Read on for further details regarding these changes, and users are always welcome in #datamapper on irc.freenode.net and we strive to any answer questions promptly.

Thank you to everyone in the community, especially this mailing list and the IRC channel. There's no way we could've reached this milestone
without your encouragement and assistance. It's extremely rewarding to see DM hit 1.0, but at the same time it also sets a baseline for future development to build on. In some ways we're only just getting started, the future we have planned for DM is even more ambitious.

Before you install
------------------

The installation process for DM 1.0 is pretty similar to what it was previously in 0.10.x and 0.9.x with a few exceptions:

1. Using auto-migration and auto-upgrading require dm-migrations rather than just dm-core. The reason for this is that dm-migrations
should share a lot of code with auto-migrations, but they don’t, and in an attempt to DRY things up we’ve centralized all the code in one
package and will begin refactoring the code over the coming months.
2. Transactions require the use of the dm-transactions gem.
3. It is no longer necessary to gem install data\_objects or any do\_*
gem directly. Each DO based adapter has been extracted into their own
gems, and installing them will setup the dependencies on dm-core and
the appropriate DO gem(s). The new adapters are:

* dm-sqlite-adapter
* dm-postgres-adaper
* dm-mysql-adapter
* dm-oracle-adapter
* dm-sqlserver-adapter

Installation
------------

Install dm-core:

`$ gem install dm-core`

The next thing you want to do is decide which adapter you want to use. For example if you want to use sqlite, do:

`$ gem install dm-sqlite-adapter`

This should pull in data\_objects and do\_sqlite3 automatically, so no need to specify either of those explicitly anymore.
It’s likely you’ll want to use migrations (for classic or auto-migrations), and transactions when using sqlite, so to install them
do:

`$ gem install dm-migrations dm-transactions`

There is also a metagem which combines several gems into a single package:

`$ gem install data_mapper`

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

`$ gem install data_mapper dm-sqlite-adapter`

Changes
-------
A lot of tickets have been addressed during the release candidate cycle and you can refer to the earlier RC notes for change details ([RC2](http://datamapper.org/articles/datamapper-100_rc2_released.html), [RC3](http://datamapper.org/articles/datamapper-100_rc3_released.html)).
You should also refer to the list of 61 tickets we've resolved for the 1.0 milestone:

[http://datamapper.lighthouseapp.com/projects/20609/milestones/62234-0103](http://datamapper.lighthouseapp.com/projects/20609/milestones/62234-0103)

How to report issues
--------------------

Please report any issues you find in IRC, on the mailing list, or inthe tracker:

* [IRC](irc://irc.freenode.net/%23datamapper)
* [Mailing List](http://groups.google.com/group/datamapper)
* [Bug Tracker](http://datamapper.lighthouseapp.com/projects/20609-datamapper)
