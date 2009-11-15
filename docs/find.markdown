---
layout:     default
title:      Finding Records
body_id:    docs
created_at: Tue Dec 04 14:46:32 +1030 2007
---

{{ page.title }}
================

The finder methods for DataMapper objects are defined in <%=
doc('DataMapper::Repository') %>. They include `get()`, `all()`, `first()`

Finder Methods
--------------

DataMapper has methods which allow you to grab a single record by key, the first
match to a set of conditions, or a collection of records matching conditions.

{% highlight ruby linenos %}
zoo   = Zoo.get(1)                        # get the zoo with primary key of 1.
zoo   = Zoo.get!(1)                       # Or get! if you want an ObjectNotFoundError on failure
zoo   = Zoo.get('DFW')                    # wow, support for natural primary keys
zoo   = Zoo.get('Metro', 'DFW')           # more wow, composite key look-up
zoo   = Zoo.first(:name => 'Luke')        # first matching record with the name 'Luke'
zoos  = Zoo.all                           # all zoos
zoos  = Zoo.all(:open => true)            # all zoos that are open
zoos  = Zoo.all(:opened_on => (s..e))     # all zoos that opened on a date in the date-range
{% endhighlight %}

Scopes and Chaining
-------------------

A call to `all()` or `first()` can be chained together to further build a query
to the data-store:

{% highlight ruby linenos %}
all_zoos = Zoo.all
open_zoos = all_zoos.all(:open => true)
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

Order
-----

To specify the order in which your results are to be sorted, use:

{% highlight ruby linenos %}
@zoos_by_tiger_count = Zoo.all(:order => [ :tiger_count.desc ])
# in SQL =>  select * from zoos ORDER BY tiger_count DESC
{% endhighlight %}

Available order vectors are:

{% highlight ruby linenos %}
asc  # sorting ascending
desc # sorting descending
{% endhighlight %}

Once you have the query, the order can be modified too.  Just call reverse:

{% highlight ruby linenos %}
@least_tigers_first = @zoos_by_tiger_count.reverse
# in SQL =>  select * from zoos ORDER BY tiger_count ASC
{% endhighlight %}

### Compatibility

DataMapper supports other conditions syntaxes as well:

{% highlight ruby linenos %}
zoos = Zoo.all(:conditions => { :id => 34 })
zoos = Zoo.all(:conditions => [ "id = ?", 34 ])

# even mix and match
zoos = Zoo.all(:conditions => { :id => 34 }, :name.like => '%foo%')
{% endhighlight %}

Talking directly to your data-store
-----------------------------------

Sometimes you may find that you need to tweak a query manually.

{% highlight ruby linenos %}
zoos = repository(:default).adapter.query('SELECT name, open FROM zoos WHERE open = 1')
#      Note that this will not return Zoo objects, rather the raw data straight from the database
{% endhighlight %}

`zoos` will be full of Struct objects with `name`, and `open` attributes, rather
than instances of the Zoo class. They'll also be read-only. You can still use
the interpolated array condition syntax as well:

{% highlight ruby linenos %}
zoos = repository(:default).adapter.query('SELECT name, open FROM zoos WHERE name = ?', "Awesome Zoo")
{% endhighlight %}

Counting
--------

With DM-More's DM-Aggregates included, the `count` method it adds will returns
an integer of the number of records matching the every condition you pass in.

{% highlight ruby linenos %}
count = Zoo.count(:age.gt => 200) #=> 2
{% endhighlight %}
