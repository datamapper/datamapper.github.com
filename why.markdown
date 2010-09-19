---
layout:     default
body_id: why
title: Why DataMapper?
---

Why DataMapper?
===============

DataMapper differentiates itself from other Ruby Object/Relational Mappers in a
number of ways:

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

Make your voice heard! [Submit a ticket or patch](http://datamapper.lighthouseapp.com/projects/20609-datamapper/),
speak up on our [mailing-list](http://groups.google.com/group/datamapper/),
chat with us on [irc](irc://irc.freenode.net/%23datamapper), write a spec,
get it reviewed, ask for commit rights. It's as easy as that to become a contributor.
