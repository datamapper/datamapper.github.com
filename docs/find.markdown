---
layout:     default
title:      Finding Records
body_id:    docs
created_at: Tue Dec 04 14:46:32 +1030 2007
---

{{ page.title }}
================

The finder methods for DataMapper objects are defined in
[DataMapper::Repository][DataMapper_Repository]. They include `#get`, `#all`, `#first`, `#last`

Finder Methods
--------------

DataMapper has methods which allow you to grab a single record by key, the first
match to a set of conditions, or a collection of records matching conditions.

{% highlight ruby linenos %}
zoo  = Zoo.get(1)                     # get the zoo with primary key of 1.
zoo  = Zoo.get!(1)                    # Or get! if you want an ObjectNotFoundError on failure
zoo  = Zoo.get('DFW')                 # wow, support for natural primary keys
zoo  = Zoo.get('Metro', 'DFW')        # more wow, composite key look-up
zoo  = Zoo.first(:name => 'Metro')    # first matching record with the name 'Metro'
zoo  = Zoo.last(:name => 'Metro')     # last matching record with the name 'Metro'
zoos = Zoo.all                        # all zoos
zoos = Zoo.all(:open => true)         # all zoos that are open
zoos = Zoo.all(:opened_on => (s..e))  # all zoos that opened on a date in the date-range
{% endhighlight %}

Scopes and Chaining
-------------------

Calls to `#all can be chained together to further build a query to the data-store:

{% highlight ruby linenos %}
all_zoos      = Zoo.all
open_zoos     = all_zoos.all(:open => true)
big_open_zoos = open_zoos.all(:animal_count => 1000)
{% endhighlight %}

As a direct consequence, you can define scopes without any extra work in your model.

{% highlight ruby linenos %}
class Zoo
  # all the keys and property setup here
  def self.open
    all(:open => true)
  end

  def self.big
    all(:animal_count => 1000)
  end
end

big_open_zoos = Zoo.big.open
{% endhighlight %}

Scopes like this can even have arguments. Do anything in them, just ensure they
return a Query of some kind.

Conditions
----------

Rather than defining conditions using SQL fragments, we can actually specify
conditions using a hash.

The examples above are pretty simple, but you might be wondering how we can
specify conditions beyond equality without resorting to SQL. Well, thanks to
some clever additions to the Symbol class, it's easy!

{% highlight ruby linenos %}
exhibitions = Exhibition.all(:run_time.gt => 2, :run_time.lt => 5)
# => SQL conditions: 'run_time > 1 AND run_time < 5'
{% endhighlight %}

Valid symbol operators for the conditions are:

{% highlight ruby linenos %}
gt    # greater than
lt    # less than
gte   # greater than or equal
lte   # less than or equal
not   # not equal
eql   # equal
like  # like
{% endhighlight %}

Nested Conditions
-----------------
DataMapper allows you to create and search for any complex object graph simply by providing a nested hash of conditions.

Possible keys are all property and relationship names (as symbols or strings) that are established in the model the current nesting level points to. The available toplevel keys depend on the model the conditions hash is passed to. We'll see below how to change the nesting level and thus the model the property and relationship keys are scoped to.

For property name keys, possible values typically are simple objects like strings, numbers, dates or booleans. Using properties as keys doesn't add another nesting level.

For relationship name keys, possible values are either a hash (if the relationship points to a single resource) or an array of hashes (if the relationship points to many resources). Adding a relationship name as key adds another nesting level scoped to the Model the relationship is pointing to. Inside this new level, the available keys are the property and relationship names of the model that the relationship points to. This is what we meant by "the Model the current nesting level points to".

The following example shows a typical Customer - Order domain model and illustrates how nested conditions can be used to both create and search for specific resources.

{% highlight ruby linenos %}
class Customer
  include DataMapper::Resource

  property :id,   Serial
  property :name, String, :required => true, :length => 1..100

  has n, :orders
  has n, :items, :through => :orders
end

class Order
  include DataMapper::Resource

  property :id,        Serial
  property :reference, String, :required => true, :length => 1..20

  belongs_to :customer

  has n, :order_lines
  has n, :items, :through => :order_lines
end

class OrderLine
  include DataMapper::Resource

  property :id,         Serial
  property :quantity,   Integer, :required => true, :default => 1, :min => 1
  property :unit_price, Decimal, :required => true, :default => lambda { |r, p| r.item.unit_price }

  belongs_to :order
  belongs_to :item
end

class Item
  include DataMapper::Resource

  property :id,         Serial
  property :sku,        String,  :required => true, :length => 1..20
  property :unit_price, Decimal, :required => true, :min => 0

  has n, :order_lines
end

# A hash specifying a customer with one order
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

# The options to create can also be used to retrieve the same object
p Customer.all(customer)

# QueryPaths can be used to construct joins in a very declarative manner.
#
# Starting from a root model, you can call any relationship by its name.
# The returned object again responds to all property and relationship names
# that are defined in the relationship's target model.
#
# This means that you can walk the chain of available relationships, and then
# match against a property at the end of that chain. The object returned by
# the last call to a property name also responds to all the comparison
# operators available in traditional queries. This makes for some powerful
# join construction!
#
Customer.all(Customer.orders.order_lines.item.sku.like => "%BLUE%")
# => [#<Customer @id=1 @name="Dan Kubb">]
{% endhighlight %}

Order
-----

To specify the order in which your results are to be sorted, use:

{% highlight ruby linenos %}
@zoos_by_tiger_count = Zoo.all(:order => [ :tiger_count.desc ])
# in SQL => SELECT * FROM "zoos" ORDER BY "tiger_count" DESC
{% endhighlight %}

Available order vectors are:

{% highlight ruby linenos %}
asc   # sorting ascending
desc  # sorting descending
{% endhighlight %}

Once you have the query, the order can be modified too.  Just call reverse:

{% highlight ruby linenos %}
@least_tigers_first = @zoos_by_tiger_count.reverse
# in SQL => SELECT * FROM "zoos" ORDER BY "tiger_count" ASC
{% endhighlight %}

Combining Queries
-----------------

Sometimes, the simple queries DataMapper allows you to specify with the hash
interface to `#all` just won't cut it.  This might be because you want to
specify an `OR` condition, though that's just one possibility.  To accomplish
more complex queries, DataMapper allows queries (or more accurately,
Collections) to be combined using set operators.

{% highlight ruby linenos %}
# Find all Zoos in Illinois, or those with five or more tigers
Zoo.all(:state => 'IL') + Zoo.all(:tiger_count.gte => 5)
# in SQL => SELECT * FROM "zoos" WHERE ("state" = 'IL' OR "tiger_count" >= 5)

# It also works with the union operator
Zoo.all(:state => 'IL') | Zoo.all(:tiger_count.gte => 5)
# in SQL => SELECT * FROM "zoos" WHERE ("state" = 'IL' OR "tiger_count" >= 5)

# Intersection produces an AND query
Zoo.all(:state => 'IL') & Zoo.all(:tiger_count.gte => 5)
# in SQL => SELECT * FROM "zoos" WHERE ("state" = 'IL' AND "tiger_count" >= 5)

# Subtraction produces a NOT query
Zoo.all(:state => 'IL') - Zoo.all(:tiger_count.gte => 5)
# in SQL => SELECT * FROM "zoos" WHERE ("state" = 'IL' AND NOT("tiger_count" >= 5))
{% endhighlight %}

Of course, the latter two queries could be achieved using the standard symbol
operators.  Set operators work on any Collection though, and so `Zoo.all(:state => 'IL')`
could just as easily be replaced with `Zoo.open.big` or any other method which
returns a collection.

Projecting only specific properties
-----------------------------------

In order to not select all of your model's properties but only a subset of
them, you can pass `:fields => [:desired, :property, :names]` in your queries.

{% highlight ruby linenos %}
# Will return a mutable collection of zoos
Zoo.all(:fields => [:id, :name])

# Will return an immutable collection of zoos.
# The collection is immutable because we haven't
# projected the primary key of the model.
# DataMapper will raise DataMapper::ImmutableError
# when trying to modify any resource inside the
# returned collection.
Zoo.all(:fields => [:name])
{% endhighlight %}

Compatibility
-------------

DataMapper supports other conditions syntaxes as well:

{% highlight ruby linenos %}
zoos = Zoo.all(:conditions => { :id => 34 })

# You can use this syntax to call native storage engine functions
zoos = Zoo.all(:conditions => [ 'id = ?', 34 ])

# even mix and match
zoos = Zoo.all(:conditions => { :id => 34 }, :name.like => '%foo%')
{% endhighlight %}

Talking directly to your data-store
-----------------------------------

Sometimes you may find that you need to tweak a query manually.

{% highlight ruby linenos %}
zoos = repository(:default).adapter.select('SELECT name, open FROM zoos WHERE open = 1')
#      Note that this will not return Zoo objects, rather the raw data straight from the database
{% endhighlight %}

`zoos` will be full of Struct objects with `name`, and `open` attributes, rather
than instances of the Zoo class. They'll also be read-only. You can still use
the interpolated array condition syntax as well:

{% highlight ruby linenos %}
zoos = repository(:default).adapter.select('SELECT name, open FROM zoos WHERE name = ?', 'Awesome Zoo')
{% endhighlight %}

Grouping
--------

DataMapper automatically groups by all selected columns in order to
return consistent results across various datastores. If you need to
group by some columns explicitly, you can use the `:fields` combined
with the `:unique` option.

{% highlight ruby linenos %}
class Person
  include DataMapper::Resource
  property :id,  Serial
  property :job, String
end

Person.auto_migrate!

# Note that if you don't include the primary key, you will need to
# specify an explicit order vector, because DM will default to the
# primary key if it's not told otherwise (at least currently).
# PostgreSQL will present this rather informative error message when
# you leave out the order vector in the query below.
#
#   column "people.id" must appear in the GROUP BY clause
#   or be used in an aggregate function
#
# To not do any ordering, you would need to provide :order => nil
#
Person.all(:fields => [:job], :unique => true, :order => [:job.asc])
# ...
# SELECT "job" FROM "people" GROUP BY "job" ORDER BY "job"
{% endhighlight %}

Note that if you don't include the primary key in the selected columns,
you will not be able to modify the returned resources because DataMapper
cannot know how to persist them. DataMapper will raise
`DataMapper::ImmutableError` if you're trying to do so nevertheless.

If a `group by` isn't appropriate and you're rather looking for `select
distinct`, you need to drop down to talking to your datastore directly,
as shown in the section above.

Aggregate functions
-------------------
For the following to work, you need to have
[dm-aggregates](http://github.com/datamapper/dm-aggregates) required.

Counting
--------

{% highlight ruby linenos %}
Friend.count # returns count of all friends
Friend.count(:age.gt => 18) # returns count of all friends older then 18
Friend.count(:conditions => [ 'gender = ?', 'female' ]) # returns count of all your female friends
Friend.count(:address) # returns count of all friends with an address (NULL values are not included)
Friend.count(:address, :age.gt => 18) # returns count of all friends with an address that are older then 18
Friend.count(:address, :conditions => [ 'gender = ?', 'female' ]) # returns count of all your female friends with an address
{% endhighlight %}

Minimum and Maximum
-------------------

{% highlight ruby linenos %}
# Get the lowest value of a property
Friend.min(:age) # returns the age of the youngest friend
Friend.min(:age, :conditions => [ 'gender = ?', 'female' ]) # returns the age of the youngest female friends
# Get the highest value of a property
Friend.max(:age) # returns the age of the oldest friend
Friend.max(:age, :conditions => [ 'gender = ?', 'female' ]) # returns the age of the oldest female friends
{% endhighlight %}

Average and Sum
---------------

{% highlight ruby linenos %}
# Get the average value of a property
Friend.avg(:age) # returns the average age of friends
Friend.avg(:age, :conditions => [ 'gender = ?', 'female' ]) # returns the average age of the female friends

# Get the total value of a property
Friend.sum(:age) # returns total age of all friends
Friend.max(:age, :conditions => [ 'gender = ?', 'female' ]) # returns the total age of all female friends
{% endhighlight %}

[DataMapper_Repository]:http://rubydoc.info/github/datamapper/dm-core/master/DataMapper/Repository
