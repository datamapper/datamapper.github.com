---
layout:       articles
categories:   articles
tags:         important
title:        DataMapper 1.1.0 released
created_at:   2011-03-16T21:22:47 +1000
summary:      DataMapper 1.1.0 is here!
author:       dkubb
---

{{ page.title }}
================

I'm pleased to announce that we have released DataMapper 1.1.

This has been one of the most enjoyable releases in recent memory. The community rallied together and compared to the previous release we had at least 3-4x more people submitting patches and working together to get this release ready.

DataMapper 1.1 brings several minor API changes, warranting the minor version bump, and closes 52 tickets in Lighthouse. There have been many performance improvements, some closing bottlenecks that result in as much as a 20x speedup from the 1.0.2 behaviour.

As part of the bug fixing process we've refactored some of the objects we use internally to group relationships and dependencies and removed methods and classes that were deprecated in 1.0.

Installation
------------

DataMapper can be installed with a one-line command:

`$ gem install datamapper dm-sqlite-adapter --no-ri --no-rdoc`

The above command assumes you are using SQLite, but if you plan to use MySQL, PostgreSQL or something else replace dm-sqlite-adapter your preferred adapter gem.

Changes
-------

Here's a [full list of the tickets we've resolved for 1.1](http://datamapper.lighthouseapp.com/projects/20609/milestones/83769).

Highlights:

* ActiveSupport / Extlib dependency is removed. If your code relies on one of these libs then just add a dependency on your own.

* `DataMapper::Type` is gone now in favour of `DataMapper::Property`. The Type API was deprecated in 1.0 but if you still have some Types floating around read how to upgrade them [in this thread](http://groups.google.com/group/datamapper/browse_thread/thread/5d3d212c3614db36/ae7be012e06488f6).

* `RelationshipSet` and `PropertySet` are now [subclasses of a new SubjectSet class](https://github.com/datamapper/dm-core/commit/e97e9af2021660dc422a035468456ddeadd499fc). Please be aware that previously `RelationshipSet` and `PropertySet` inherited from `Hash` and `Array`, respectively.

* The property class finder is now improved and it is possible to declare properties that aren't defined in `DataMapper::Property` namespace without providing the full const path. For instance you can have `YourApp::Properties::FooBar` and you can declare it as `property :foo_bar, FooBar`. There's a convention that if your property class has the same name as one of the other properties from `DataMapper::Property` namespace then you have to provide the full const path, otherwise your property won't be found.

* Removed deprecated methods:

      DataMapper::Collection#add (replaced by #<<)
      DataMapper::Collection#build (replaced by #new)
      DataMapper::IdentityMap#get (replaced by #[])
      DataMapper::IdentityMap#set (replaced by #[]=)
      DataMapper::PropertySet#has_property? (replaced by #named?)
      DataMapper::PropertySet#slice (replaced by #values_at)
      DataMapper::PropertySet#add (replaced by #<<)
      DataMapper::Query::Conditions::Comparison#property (replaced by #subject)
      DataMapper::Query::Direction#property (replaced by #subject)
      DataMapper::Query::Direction#direction (replaced by #operator)
      DataMapper::Property#unique (replaced by #unique?)
      DataMapper::Property#nullable? (replaced by #allow_nil?)
      DataMapper::Property#value (replaced by #dump)
      DataMapper::Resource#new_record? (replaced by #new?)

How to report issues
--------------------

Please report any issues you find in IRC, on the mailing list, or in the bug tracker:

* [IRC](irc://irc.freenode.net/%23datamapper)
* [Mailing List](http://groups.google.com/group/datamapper)
* [Bug Tracker](http://datamapper.lighthouseapp.com/projects/20609-datamapper)
