---
layout:     default
page_id:    gettingStarted
title:      Getting started with DataMapper
created_at: Wed Aug 29 20:36:53 +0930 2007
---

{{page.title}}
==============

First, if you think you might need some help, there's an active community
supporting DataMapper through
[the mailing list](http://groups.google.com/group/datamapper) and the `#datamapper` IRC
channel on irc.freenode.net.

So lets imagine we're setting up some models for a blogging app. We'll keep it
nice and simple. The first thing to decide on is what models we want. Post is a
given. So is Comment. But let's mix it up and do Category too.

Install DataMapper
------------------

If you have RubyGems installed, pop open your console and install a few things.

{% highlight ruby %}
gem install data_mapper
{% endhighlight %}

This will install the following, most commonly used DataMapper gems.

* [dm-core](http://github.com/datamapper/dm-core)
* [dm-aggregates](http://github.com/datamapper/dm-aggregates)
* [dm-constraints](http://github.com/datamapper/dm-constraints)
* [dm-migrations](http://github.com/datamapper/dm-migrations)
* [dm-transactions](http://github.com/datamapper/dm-transactions)
* [dm-serializer](http://github.com/datamapper/dm-serializer)
* [dm-timestamps](http://github.com/datamapper/dm-timestamps)
* [dm-validations](http://github.com/datamapper/dm-validations)
* [dm-types](http://github.com/datamapper/dm-types)

If you are planning on using DataMapper with a database, install a database
driver from the DataObjects project: (Substitute `dm-sqlite-adapter` with `dm-postgres-adapter` or `dm-mysql-adapter` depending on your preferences)

{% highlight ruby %}
gem install dm-sqlite-adapter
{% endhighlight %}

Require it in your application
------------------------------

{% highlight ruby %}
require 'rubygems'
require 'data_mapper' # requires all the gems listed above
{% endhighlight %}

Specify your database connection
--------------------------------

You need to make sure to do this before you use your models, i.e. before you actually start accessing the database.

{% highlight ruby %}
  # If you want the logs displayed you have to do this before the call to setup
  DataMapper::Logger.new($stdout, :debug)

  # An in-memory Sqlite3 connection:
  DataMapper.setup(:default, 'sqlite::memory:')

  # A Sqlite3 connection to a persistent database
  DataMapper.setup(:default, 'sqlite:///path/to/project.db')

  # A MySQL connection:
  DataMapper.setup(:default, 'mysql://localhost/the_database_name')

  # A Postgres connection:
  DataMapper.setup(:default, 'postgres://localhost/the_database_name')
{% endhighlight %}

Define your models
------------------

The Post model is going to need to be persistent, so we'll include
[DataMapper::Resource][DataMapper_Resource]. The convention with model names is to use the
singular, not plural version...but that's just the convention, you can do
whatever you want.

{% highlight ruby %}
class Post
  include DataMapper::Resource

  property :id,         Serial    # An auto-increment integer key
  property :title,      String    # A varchar type string, for short strings
  property :body,       Text      # A text block, for longer string data.
  property :created_at, DateTime  # A DateTime, for any date you might like.
end

class Comment
  include DataMapper::Resource

  property :id,         Serial
  property :posted_by,  String
  property :email,      String
  property :url,        String
  property :body,       Text
end

class Category
  include DataMapper::Resource

  property :id,         Serial
  property :name,       String
end
{% endhighlight %}

The above example is simplified, but you can also specify more options such as
constraints for your properties.  DataMapper supports a lot of different
[property](/docs/properties) types natively, and more through
[dm-types](/docs/dm_more/types).

An important thing to note is that every model *must* have a key in
order to be valid. If a model has no key, there's no way to identify a
resource and thus no way to update its persistent state within the
backend datastore. DataMapper will raise a `DataMapper::IncompleteModelError`
when trying to `auto_migrate!` a model that has no key declared.

Have a look at [property](/docs/properties) to learn about the different
ways of declaring keys for your models.

Associations
------------

Ideally, these declarations should be done inside your class definition with the
properties and things, but for demonstration purposes, we’re just going to crack
open the classes.

### One To Many

Posts can have comments, so we’ll need to setup a simple
[one-to-many](/docs/associations#has_n_and_belongs_to_or_onetomany) association
between then:

{% highlight ruby %}
class Post
  has n, :comments
end

class Comment
  belongs_to :post
end
{% endhighlight %}

### Has and belongs to many

Has and belongs to many Categories can have many Posts and Posts can have many
Categories, so we’ll need a
[many to many](/docs/associations#has_n_through_or_onetomanythrough) relationships
commonly referred to “has and belongs to many”. We’ll setup a quick model to
wrap our join table between the two so that we can record a little bit of
meta-data about when the post was categorized into a category.

{% highlight ruby %}

class Categorization
  include DataMapper::Resource

  property :id,         Serial
  property :created_at, DateTime

  belongs_to :category
  belongs_to :post
end

# Now we re-open our Post and Categories classes to define associations
class Post
  has n, :categorizations
  has n, :categories, :through => :categorizations
end

class Category
  has n, :categorizations
  has n, :posts,      :through => :categorizations
end

{% endhighlight %}

Finalize Models
---------------

After declaring all of the models, you should finalize them:

{% highlight ruby %}
DataMapper.finalize
{% endhighlight %}

This checks the models for validity and initializes all properties associated
with relationships.  It is likely if you use a web-framework such as merb or
rails, this will already be done for you. In case you do not, be sure to call it
at an appropriate time.

DataMapper allows the use of natural primary keys, composite primary keys and
other complexities.  Because of this, when a model is declared with a
`belongs_to` relationship the property to hold the foreign key cannot be
initialized immediately.  It can only be initialized when the parent model has
also been declared.  This is hard for DataMapper to determine, due to the
dynamic nature of ruby, so it is left up to developers to determine the
appropriate time.

In general, you want to call `finalize` *before* your application starts
accessing the models.

Set up your database tables
---------------------------

Relational Databases work with pre-defined tables. To be able to create the tables in the
underlying storage, you need to have `dm-migrations` available on your load path.

If you've been following this instructions and did `require 'data_mapper'`,
you can safely skip the following require statement as it has already
been done for you.

{% highlight ruby %}
require  'dm-migrations'
{% endhighlight %}

Once you made sure that `dm-migrations` is available, you can create the tables by issuing the following command.

{% highlight ruby %}
DataMapper.auto_migrate!
{% endhighlight %}

This will issue the necessary `CREATE` statements (`DROP`ing the table first, if
it exists) to define each storage according to their properties. After
`auto_migrate!` has been run, the database should be in a pristine state.  All
the tables will be empty and match the model definitions.

This wipes out existing data, so you could also do:

{% highlight ruby %}
DataMapper.auto_upgrade!
{% endhighlight %}

This tries to make the schema match the model.  It will `CREATE` new tables, and
add columns to existing tables.  It won't change any existing columns though
(say, to add a NOT NULL constraint) and it doesn't drop any columns.  Both these commands
also can be used on an individual model (e.g. `Post.auto_migrate!`)

Create your first resource
--------------------------

Using DataMapper to [create](/docs/create_and_destroy#creating) a resource (A
resource is an instance of a model) is simple

{% highlight ruby %}
# create makes the resource immediately
@post = Post.create(
  :title      => "My first DataMapper post",
  :body       => "A lot of text ...",
  :created_at => Time.now
)

# Or new gives you it back unsaved, for more operations
@post = Post.new(:title => ..., ...)
@post.save                           # persist the resource
{% endhighlight %}

Both are equivalent.  The first thing to notice is we didn't specify the
auto-increment key.  This is because the data-store will provide that value for
us, and should make sure it's unique, too.  Also, note that while the property
is a `DateTime`, we can pass it a `Time` instance, and it will convert (or
typecast) the value for us, before it saves it to the data-store.  Any
properties which are not specified in the hash will take their default values in
the data-store.

[DataMapper_Resource]:http://rubydoc.info/github/datamapper/dm-core/master/DataMapper/Resource
