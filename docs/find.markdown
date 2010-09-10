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
in    # in - will be used automatically when an array is passed in as an argument
{% endhighlight %}

Nested Conditions
-----------------
DataMapper allows you to create and search for any complex object graph simply by providing a nested hash of conditions.

Possible keys are all properties and relationships (or simply their names as symbols or strings) established in the model the current nesting level points to. The available toplevel keys depend on the model the conditions hash is passed to. We'll see below how to change the nesting level and thus the model the property and relationship keys are scoped to.

For property (name) keys, possible values typically are simple objects like strings, numbers, dates or booleans. Using properties as keys doesn't add another nesting level.

For relationship (name) keys, possible values are either a hash (if the relationship points to a single resource) or an array of hashes (if the relationship points to many resources). Adding a relationship (name) as key adds another nesting level scoped to the Model the relationship is pointing to. Inside this new level, the available keys are the property and relationship (names) of the model that the relationship points to. This is what we meant by "the Model the current nesting level points to".

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
  property :unit_price, Decimal, :required => true, :default => lambda { |r,p| r.item.unit_price }

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
{% endhighlight %}

Order
-----

To specify the order in which your results are to be sorted, use:

{% highlight ruby linenos %}
@zoos_by_tiger_count = Zoo.all(:order => [ :tiger_count.desc ])
# in SQL =>  SELECT * FROM zoos ORDER BY tiger_count DESC
{% endhighlight %}

Available order vectors are:

{% highlight ruby linenos %}
asc   # sorting ascending
desc  # sorting descending
{% endhighlight %}

Once you have the query, the order can be modified too.  Just call reverse:

{% highlight ruby linenos %}
@least_tigers_first = @zoos_by_tiger_count.reverse
# in SQL =>  SELECT * FROM zoos ORDER BY tiger_count ASC
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

Compatibility
-------------

DataMapper supports other conditions syntaxes as well:

{% highlight ruby linenos %}
zoos = Zoo.all(:conditions => { :id => 34 })

# You can use this syntax to call native storage engine functions
zoos = Zoo.all(:conditions => [ "id = ?", 34 ])

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
zoos = repository(:default).adapter.select('SELECT name, open FROM zoos WHERE name = ?', "Awesome Zoo")
{% endhighlight %}

Counting
--------

With dm-aggregates included, the `count` method it adds will returns
an integer of the number of records matching the every condition you pass in.

{% highlight ruby linenos %}
count = Zoo.count(:age.gt => 200)  # => 2
{% endhighlight %}

[DataMapper_Repository]:http://www.yardoc.org/docs/datamapper-dm-core/DataMapper/Repository
