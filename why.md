---
layout:     default
body_id: why
title: Why DataMapper?
---

Why DataMapper?
===============

DataMapper differentiates itself from other Ruby Object/Relational Mappers in a
number of ways:

One API for a variety of datastores
-----------------------------------

DataMapper comes with the ability to use the same API to talk to a
multitude of different datastores. There are adapters for the usual
RDBMS suspects, NoSQL stores, various file formats and even some popular
webservices.

There's a probably incomplete list of available datamapper adapters on
the [github wiki](http://github.com/datamapper/dm-core/wiki/Adapters)
with new ones getting implemented regularly. A quick
[github search](http://github.com/search?q=dm+adapter&type=Everything&repo=&langOverride=&start_value=1)
should give you further hints on what's currently available.

Plays Well With Others
----------------------

With DataMapper you define your mappings in your model. Your data-store can
develop independently of your models using Migrations.

To support data-stores which you don't have the ability to manage yourself, it's
simply a matter of telling DataMapper where to look. This makes DataMapper
a good choice when [Working with legacy databases](/docs/legacy)

{% highlight ruby linenos %}
class Post
  include DataMapper::Resource

  # set the storage name for the :legacy repository
  storage_names[:legacy] = 'tblPost'

  # use the datastore's 'pid' field for the id property.
  property :id, Serial, :field => :pid

  # use a property called 'uid' as the child key (the foreign key)
  belongs_to :user, :child_key => [ :uid ]
end
{% endhighlight %}

DataMapper only issues updates or creates for the properties it knows about. So
it plays well with others. You can use it in an Integration Database without
worrying that your application will be a bad actor causing trouble for all of
your other processes.

DataMapper has full support for Composite Primary Keys (CPK) builtin.
Specifying the properties that form the primary key is easy.

{% highlight ruby linenos %}
class LineItem
  include DataMapper::Resource

  property :order_id,    Integer, :key => true
  property :item_number, Integer, :key => true
end
{% endhighlight %}

If we were to know an `order_id`/`item_number` combination, we can
easily retrieve the corresponding line item from the datastore.

{% highlight ruby linenos %}
order_id, item_number = 1, 1
LineItem.get(order_id, item_number)
# => [#<LineItem @orderid=1 @item_number=1>]
{% endhighlight %}

Less need for writing migrations
--------------------------------

With DataMapper, you specify the datastore layout inside your ruby
models. This allows DataMapper to create the underlying datastore schema
based on the models you defined. The `#auto_migrate!` and `#auto_upgrade!`
methods can be used to generate a schema in the datastore that matches
your model definitions.

While `#auto_migrate!` *destructively* drops and recreates tables to match
your model definitions, `#auto_upgrade!` supports upgrading your
datastore to match your model definitions, without actually destroying
any already existing data.

There are still some limitations to the operations that `#auto_upgrade!`
can perform. We're working hard on making it smarter, but there will
always be scenarios where an automatic upgrade of your schema won't be
possible. For example, there's no sane strategy for automatically changing
a column length constraint from `VARCHAR(100)` to `VARCHAR(50)`. DataMapper
can't know what it should do when the data doesn't validate against the
new tightened constraints.

In situations where neither `#auto_migrate!` nor `#auto_upgrade!` quite cut
it, you can still fall back to the classic migrations feature provided
by [dm-migrations](http://github.com/datamapper/dm-migrations).

Here's some code that puts `#auto_migrate!` and `#auto_upgrade!` to use.

{% highlight ruby linenos %}
require 'rubygems'
require 'dm-core'
require 'dm-migrations'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'mysql://localhost/test')

class Person
  include DataMapper::Resource
  property :id,   Serial
  property :name, String, :required => true
end

DataMapper.auto_migrate!

# ~ (0.015754) SET sql_auto_is_null = 0
# ~ (0.000335) SET SESSION sql_mode = 'ANSI,NO_BACKSLASH_ESCAPES,NO_DIR_IN_CREATE,NO_ENGINE_SUBSTITUTION,NO_UNSIGNED_SUBTRACTION,TRADITIONAL'
# ~ (0.283290) DROP TABLE IF EXISTS `people`
# ~ (0.029274) SHOW TABLES LIKE 'people'
# ~ (0.000103) SET sql_auto_is_null = 0
# ~ (0.000111) SET SESSION sql_mode = 'ANSI,NO_BACKSLASH_ESCAPES,NO_DIR_IN_CREATE,NO_ENGINE_SUBSTITUTION,NO_UNSIGNED_SUBTRACTION,TRADITIONAL'
# ~ (0.000932) SHOW VARIABLES LIKE 'character_set_connection'
# ~ (0.000393) SHOW VARIABLES LIKE 'collation_connection'
# ~ (0.080191) CREATE TABLE `people` (`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT, `name` VARCHAR(50) NOT NULL, PRIMARY KEY(`id`)) ENGINE = InnoDB CHARACTER SET utf8 COLLATE utf8_general_ci
# => #<DataMapper::DescendantSet:0x101379a68 @descendants=[Person]>

class Person
  property :hobby, String
end

DataMapper.auto_upgrade!

# ~ (0.000612) SHOW TABLES LIKE 'people'
# ~ (0.000079) SET sql_auto_is_null = 0
# ~ (0.000081) SET SESSION sql_mode = 'ANSI,NO_BACKSLASH_ESCAPES,NO_DIR_IN_CREATE,NO_ENGINE_SUBSTITUTION,NO_UNSIGNED_SUBTRACTION,TRADITIONAL'
# ~ (1.794475) SHOW COLUMNS FROM `people` LIKE 'id'
# ~ (0.001412) SHOW COLUMNS FROM `people` LIKE 'name'
# ~ (0.001121) SHOW COLUMNS FROM `people` LIKE 'hobby'
# ~ (0.153989) ALTER TABLE `people` ADD COLUMN `hobby` VARCHAR(50)
# => #<DataMapper::DescendantSet:0x101379a68 @descendants=[Person]>
{% endhighlight %}

Data integrity is important
---------------------------

DataMapper makes it easy to leverage native techniques for enforcing
data integrity. The [dm-constraints](http://github.com/datamapper/dm-constraints)
plugin provides support for establishing true foreign key constraints in
databases that support that concept.

{% highlight ruby linenos %}
require 'rubygems'
require 'dm-core'
require 'dm-constraints'
require 'dm-migrations'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'mysql://localhost/test')

class Person
  include DataMapper::Resource
  property :id, Serial
  has n, :tasks, :constraint => :destroy
end

class Task
  include DataMapper::Resource
  property :id, Serial
  belongs_to :person
end

DataMapper.auto_migrate!

# ~ (0.000131) SET sql_auto_is_null = 0
# ~ (0.000141) SET SESSION sql_mode = 'ANSI,NO_BACKSLASH_ESCAPES,NO_DIR_IN_CREATE,NO_ENGINE_SUBSTITUTION,NO_UNSIGNED_SUBTRACTION,TRADITIONAL'
# ~ (0.017995) SHOW TABLES LIKE 'people'
# ~ (0.000278) SHOW TABLES LIKE 'tasks'
# ~ (0.001435) DROP TABLE IF EXISTS `people`
# ~ (0.000226) SHOW TABLES LIKE 'people'
# ~ (0.000093) SET sql_auto_is_null = 0
# ~ (0.000087) SET SESSION sql_mode = 'ANSI,NO_BACKSLASH_ESCAPES,NO_DIR_IN_CREATE,NO_ENGINE_SUBSTITUTION,NO_UNSIGNED_SUBTRACTION,TRADITIONAL'
# ~ (0.000334) SHOW VARIABLES LIKE 'character_set_connection'
# ~ (0.000278) SHOW VARIABLES LIKE 'collation_connection'
# ~ (0.187402) CREATE TABLE `people` (`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY(`id`)) ENGINE = InnoDB CHARACTER SET utf8 COLLATE utf8_general_ci
# ~ (0.000309) DROP TABLE IF EXISTS `tasks`
# ~ (0.000313) SHOW TABLES LIKE 'tasks'
# ~ (0.200487) CREATE TABLE `tasks` (`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT, `person_id` INT(10) UNSIGNED NOT NULL, PRIMARY KEY(`id`)) ENGINE = InnoDB CHARACTER SET utf8 COLLATE utf8_general_ci
# ~ (0.146982) CREATE INDEX `index_tasks_person` ON `tasks` (`person_id`)
# ~ (0.002525) SELECT COUNT(*) FROM "information_schema"."table_constraints" WHERE "constraint_type" = 'FOREIGN KEY' AND "table_schema" = 'test' AND "table_name" = 'tasks' AND "constraint_name" = 'tasks_person_fk'
# ~ (0.230075) ALTER TABLE `tasks` ADD CONSTRAINT `tasks_person_fk` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
# => #<DataMapper::DescendantSet:0x101379a68 @descendants=[Person, Task]>
{% endhighlight %}

Notice how the last statement adds a foreign key constraint to the
schema definition.

Strategic Eager Loading
-----------------------

DataMapper will only issue the very bare minimums of queries to your data-store
that it needs to. For example, the following example will only issue 2 queries.
Notice how we don't supply any extra `:include` information.

{% highlight ruby linenos %}
zoos = Zoo.all
zoos.each do |zoo|
  # on first iteration, DM loads up all of the exhibits for all of the items in zoos
  # in 1 query to the data-store.

  zoo.exhibits.each do |exhibit|
    # n+1 queries in other ORMs, not in DataMapper
    puts "Zoo: #{zoo.name}, Exhibit: #{exhibit.name}"
  end
end
{% endhighlight %}

The idea is that you aren't going to load a set of objects and use only an
association in just one of them. This should hold up pretty well against a 99%
rule.

When you don't want it to work like this, just load the item you want in it's
own set. So DataMapper thinks ahead. We like to call it "performant by default".
*This feature single-handedly wipes out the "N+1 Query Problem".*

DataMapper also waits until the very last second to actually issue the query to
your data-store. For example, `zoos = Zoo.all` won't run the query until you
start iterating over `zoos` or call one of the 'kicker' methods like `#length`.
If you never do anything with the results of a query, DataMapper won't incur the
latency of talking to your data-store.

**Note:** that this currently doesn't work when you start to nest loops
that access the associations more than one level deep. The following
would *not* issue the optimal amount of queries:

{% highlight ruby linenos %}
zoos = Zoo.all
zoos.each do |zoo|
  # on first iteration, DM loads up all of the exhibits for all of the items in zoos
  # in 1 query to the data-store.

  zoo.exhibits.each do |exhibit|
    # n+1 queries in other ORMs, not in DataMapper
    puts "Zoo: #{zoo.name}, Exhibit: #{exhibit.name}"

    exhibit.items.each do |item|
      # currently DM won't be smart about the queries it generates for
      # accessing the items in any particular exhibit
      puts "Item: #{item.name}"
    end
  end
end
{% endhighlight %}

However, there's work underway to remove that limitation. In the future,
it will be possible to get the same smart queries inside deeper nested
iterations.

Depending on your specific needs, it might be possible to workaround
this limitations by using DataMapper's feature that allows you to query
models by their associations, as described briefly in the chapter below.

You can also find more information about this feature on the
[Finders](/docs/find) and the [Associations](/docs/associations) pages.

Querying models by their associations
-------------------------------------

DataMapper allows you to create and search for any complex object graph simply by providing a nested hash of conditions. The following example uses a typical Customer - Order domain model to illustrate how nested conditions can be used to both create and query models by their associations.

For a complete definition of the Customer - Order domain models have a look at the [Finders](/docs/find) page.

{% highlight ruby linenos %}
# A hash specifying one customer with one order
#
# In general, possible keys are all property and relationship
# names that are available on the relationship's target model.
# Possible toplevel keys depend on the property and relationship
# names available in the model that receives the hash.
#
customer = {
  :name   => 'Dan Kubb',
  :orders => [
    {
      :reference   => 'TEST1234',
      :order_lines => [
        {
          :item => {
            :sku        => 'BLUEWIDGET1',
            :unit_price => 1.00,
          },
        },
      ],
    },
  ]
}

# Create the Customer with the nested options hash
Customer.create(customer)
# => [#<Customer @id=1 @name="Dan Kubb">]

# The same options to create can also be used to query for the same object
p Customer.all(customer)
# => [#<Customer @id=1 @name="Dan Kubb">]
{% endhighlight %}

QueryPaths can be used to construct joins in a very declarative manner.

Starting from a root model, you can call any relationship by its name.
The returned object again responds to all property and relationship names
that are defined in the relationship's target model.

This means that you can walk the chain of available relationships, and then
match against a property at the end of that chain. The object returned by
the last call to a property name also responds to all the comparison
operators that we saw above. This makes for some powerful join construction!

{% highlight ruby linenos %}
Customer.all(Customer.orders.order_lines.item.sku.like => "%BLUE%")
# => [#<Customer @id=1 @name="Dan Kubb">]
{% endhighlight %}

You can even chain calls to `all` or `first` to continue refining your query or
search within a scope. See [Finders](/docs/find) for more information.


Identity Map
------------

One row in the database should equal one object reference. Pretty simple idea.
Pretty profound impact. If you run the following code in ActiveRecord you'll see
all `false` results. Do the same in DataMapper and it's `true` all the way down.

{% highlight ruby linenos %}
@parent = Tree.first(:conditions => { :name => 'bob' })

@parent.children.each do |child|
  puts @parent.object_id == child.parent.object_id
end
{% endhighlight %}

This makes DataMapper faster and allocate less resources to get things done.

Laziness Can Be A Virtue
------------------------

Columns of potentially infinite length, like Text columns, are expensive in
data-stores. They're generally stored in a different place from the rest of your
data. So instead of a fast sequential read from your hard-drive, your data-store
has to hop around all over the place to get what it needs.

With DataMapper, these fields are treated like in-row associations by default,
meaning they are loaded if and only if you access them. If you want more control
you can enable or disable this feature for any column (not just text-fields) by
passing a `lazy` option to your column mapping with a value of `true` or
`false`.

{% highlight ruby linenos %}
class Animal
  include DataMapper::Resource

  property :id,    Serial
  property :name,  String
  property :notes, Text    # lazy-loads by default
end
{% endhighlight %}

Plus, lazy-loading of Text property happens automatically and intelligently when
working with associations. The following only issues 2 queries to load up all of
the notes fields on each animal:

{% highlight ruby linenos %}
animals = Animal.all
animals.each do |pet|
  pet.notes
end
{% endhighlight %}

Embracing Ruby
--------------

DataMapper loves Ruby and is therefore tested regularly against all
major Ruby versions. Before release, every gem is explicitly tested
against MRI 1.8.7, 1.9.2, JRuby and Rubinius. We're proud to say that
almost all of our specs pass on all these different implementations.

Have a look at our [CI server reports](http://ci.datamapper.org)
for detailed information about which gems pass or fail their specs on
the various Ruby implementations. Note that these results always reflect
the state of the latest codes and not the state of the latest released
gem. Our CI server runs tests for all permutations whenever someone
commits to any of the tested repositories on Github.

All Ruby, All The Time
----------------------

DataMapper goes further than most Ruby ORMs in letting you avoid writing raw
query fragments yourself. It provides more helpers and a unique hash-based
conditions syntax to cover more of the use-cases where issuing your own SQL
would have been the only way to go.

For example, any finder option that are non-standard is considered a condition.
So you can write `Zoo.all(:name => 'Dallas')` and DataMapper will look for zoos
with the name of 'Dallas'.

It's just a little thing, but it's so much nicer than writing
`Zoo.find(:all, :conditions => [ 'name = ?', 'Dallas' ])` and won't incur the
Ruby overhead of
`Zoo.find_by_name('Dallas')`, nor is it more difficult to understand once the
number of parameters increases.

What if you need other comparisons though? Try these:

{% highlight ruby linenos %}
Zoo.first(:name => 'Galveston')

# 'gt' means greater-than. 'lt' is less-than.
Person.all(:age.gt => 30)

# 'gte' means greather-than-or-equal-to. 'lte' is also available
Person.all(:age.gte => 30)

Person.all(:name.not => 'bob')

# If the value of a pair is an Array, we do an IN-clause for you.
Person.all(:name.like => 'S%', :id => [ 1, 2, 3, 4, 5 ])

# Does a NOT IN () clause for you.
Person.all(:name.not => [ 'bob', 'rick', 'steve' ])

# Ordering
Person.all(:order => [ :age.desc ])
# .asc is the default
{% endhighlight %}

Open Development
----------------

DataMapper sports a very accessible code-base and a welcoming community. Outside
contributions and feedback are welcome and encouraged, especially constructive
criticism. Go ahead, fork DataMapper, we'd love to see what you come up with!

Make your voice heard! [Submit a ticket or patch](http://github.com/datamapper/dm-core/issues),
speak up on our [mailing-list](http://groups.google.com/group/datamapper/),
chat with us on [irc](irc://irc.freenode.net/%23datamapper), write a spec,
get it reviewed, ask for commit rights. It's as easy as that to become a contributor.
