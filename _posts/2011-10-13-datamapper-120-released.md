---
layout:       articles
categories:   articles
tags:         important
title:        DataMapper 1.2.0 released
created_at:   2011-10-13T11:47:32 +1000
summary:      DataMapper 1.2.0 is here!
author:       solnic
---

{{ page.title }}
================

I'm pleased to announce that we have released DataMapper 1.2.0.

This release is focused on bug fixes, performance improvements, internal
refactoring and *Rails 3.1 compatibility*. Please give it a try and in case of
any issues please report them on Github.

Installation
------------

DataMapper can be installed with a one-line command:

`$ gem install data_mapper dm-sqlite-adapter`

The above command assumes you are using SQLite, but if you plan to use MySQL, PostgreSQL or something else replace dm-sqlite-adapter your preferred adapter gem.

IMPORTANT:

If you're not using Rails then remember to call `DataMapper.finalize` after loading the models!

Changes
-------

dm-core:

- STI queries no longer include the top-level class name
- UnderscoredAndPluralizedWithoutLeadingModule naming convention was added
- belongs_to supports :unique option
- Validation of property names was improved
- Resource[] and Resource[]= no longer fail when property name is not known
- Redundant usage of chainable was removed resulting in a better performance
- Boolean property typecasting was refactored
- Various issues with setting default Property options were fixed
- Resource#attributes= no longer use public\_method\_defined? - this is a security fix preventing possible DDOS attacks
- Problems with auto-migrations in multiple repositories were fixed
- Encoding problems with Binary property are fixed

dm-adjust:

- Support for InMemoryAdapter
- Add COALESCE to default NULL columns to 0
- Fixed a bug with loading dm-adjust after the dm-do-adapter

dm-constraints:

- Total rewrite
- Fixed for Oracle

dm-do-adapter:

- Warning from DO is gone now

dm-migrations:

- alter table is fixed for postgres
- Property options (such as :length) are now correctly used in migrations
- Support to specify table options when creating a table was added (for things like db engines in mysql etc.)
- Fix bug related to migrating custom types derived from builtin types

dm-rails:

- Support for Rails 3.1.0
- Storage create/drop tasks are by default noops in case an adapter doesn't support it
- Support for field_naming_convention option
- Support for resource_naming_convention option
- You can now set a custom repository scope for the repository in the IdentityMap middleware

dm-serializer:

- *Should* work with psych

dm-types:

- Support for Resource#dirty? upon indirect property mutation was added (this is huge, more info here: https://github.com/datamapper/dm-types/commit/3d96b1cd2b270a3843877a5...)
- Issues with Paranoid properties and STI were fixed
- JSON property uses multi_json now

dm-validations:

- #valid? is always called even if a resource is not dirty
- Issues with JRuby and unicode were fixed
- Massive internal clean-up towards future rewrite that will make validations even more awesome

dm-oracle-adapter:

- Many bug fixes
- Important: on MRI it requires ruby-oci8 gem (it's not specified in the gemspec, you need to add it to your gemfiles)
