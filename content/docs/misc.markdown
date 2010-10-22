---
layout:     default
title:      Miscellaneous Features
created_at: Thu Mar 20 23:26:54 -0500 2008
---

<%= @item[:title] %>
================

DataMapper comes loaded features, many of which other ORMs require external
libraries for.

Single Table Inheritance
------------------------

Many ORMs support Single Table Inheritance and DataMapper is no different. In
order to declare a model for Single Table Inheritance, define a property with
the data-type of [Types::Discriminator][Types_Discriminator].

<pre><code class="language-ruby">
class Person
  include DataMapper::Resource

  property :name, String
  property :job,  String,        :length => 1..255
  property :type, Discriminator
  ...
end

class Male   < Person; end
class Father < Male;   end
class Son    < Male;   end

class Woman    < Person; end
class Mother   < Woman;  end
class Daughter < Woman;  end

</code></pre>

When DataMapper sees your `type` column declared as type
[Types::Discriminator][Types_Discriminator], it will automatically insert the class name of
the object you've created and later instantiate that row as that class. It also
supports deep inheritance, so doing Woman.all will select all women, mothers,
and daughters (and deeper inherited classes if they exist).

Paranoia
--------

Sometimes...most times...you don't _really_ want to destroy a row in the
database, you just want to mark it as deleted so that you can restore it later
if need be. This is aptly-named Paranoia and DataMapper has basic support for
this baked right in. Just declare a property and assign it a type of
[Types::ParanoidDateTime][Types_ParanoidDateTime] or [Types::ParanoidBoolean][Types_ParanoidBoolean]:

<pre><code class="language-ruby">
property :deleted_at, ParanoidDateTime
</code></pre>

Multiple Data-Store Connections
-------------------------------

DataMapper sports a concept called a context which encapsulates the data-store
context in which you want operations to occur. For example, when you setup a
connection in [getting-started](/getting-started), you were defining a
context known as `:default`

<pre><code class="language-ruby">
  DataMapper.setup(:default, 'mysql://localhost/dm_core_test')
</code></pre>

If you supply another context name, you will now have 2 database contexts with
their own unique loggers, connection pool, identity map....one default context
and one named context.

<pre><code class="language-ruby">
DataMapper.setup(:external, 'mysql://someother_host/dm_core_test')
</code></pre>

To use one context rather than another, simply wrap your code block inside a
`repository` call. It will return whatever your block of code returns.

<pre><code class="language-ruby">
DataMapper.repository(:external) { Person.first }
# hits up your :external database and retrieves the first Person
</code></pre>

This will use your connection to the `:external` data-store and the first Person
it finds. Later, when you call `.save` on that person, it'll get saved back to
the `:external` data-store; An object is aware of what context it came from and
should be saved back to.

NOTE that currently you **must** setup a `:default` repository to work
with DataMapper (and to be able to use additional differently named
repositories). This might change in the future.

Chained Associations
--------------------

Say you want to find all of the animals in a zoo, but Animal belongs to Exhibit
which belongs to Zoo. Other ORMs solve this problem by providing a means to
describe the double JOINs into the retrieval call for Animals. ActiveRecord
specifically will let you specify JOINs in a hash-of-hashes syntax which will
make most developers throw up a little in their mouths.

DataMapper's solution is to let you chain association calls:

<pre><code class="language-ruby">
zoo = Zoo.first
zoo.exhibits.animals  # retrieves all animals for all exhibits for that zoo
</code></pre>

This has great potential for browsing collections of content, like browsing all
blog posts' comments by category or tag. At present, chaining beyond 2
associations is still experimental.

[Types_Discriminator]:http://rubydoc.info/github/datamapper/dm-core/master/DataMapper/Property/Discriminator
[Types_ParanoidDateTime]:http://rubydoc.info/github/datamapper/dm-types/master/DataMapper/Property/ParanoidDateTime
[Types_ParanoidBoolean]:http://rubydoc.info/github/datamapper/dm-types/master/DataMapper/Property/ParanoidBoolean
