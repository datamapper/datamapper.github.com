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
gem install dm-core
{% endhighlight %}

If you are planning on using DataMapper with a database, install a database
driver from the DataObjects project: (Substitute `do_sqlite3` with `do_postgres`
or `do_mysql` depending on your preferences)

{% highlight ruby %}
gem install do_sqlite3
{% endhighlight %}

Require it in your application
------------------------------

{% highlight ruby %}
require 'rubygems'
require 'dm-core'
{% endhighlight %}

Specify your database connection
--------------------------------

You need make sure this is set before you define your models.

{% highlight ruby %}
  # If you want the logs displayed you have to do this before the call to setup
  DataMapper::Logger.new($stdout, :debug)

  # An in-memory Sqlite3 connection:
  DataMapper.setup(:default, 'sqlite3::memory:')

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

  property :id,         Serial
  property :title,      String
  property :body,       Text
  property :created_at, DateTime
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
constraints for your properties.

Associations
------------

Ideally, these declarations should be done inside your class definition with the
properties and things, but for demonstration purposes, we’re just going to crack
open the classes.

### One To Many

Posts can have comments, so we’ll need to setup a simple one-to-many association
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
Categories, so we’ll need a many to many relationships commonly referred to “has
and belongs to many”. We’ll setup a quick model to wrap our join table between
the two so that we can record a little bit of meta-data about when the post was
categorized into a category.

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

Set up your database tables
---------------------------

{% highlight ruby %}
Post.auto_migrate!
Category.auto_migrate!
Comment.auto_migrate!
Categorization.auto_migrate!
{% endhighlight %}

This will issue the necessary `CREATE` statements to define each storage according
to their properties.

You could also do:

{% highlight ruby %}
DataMapper.auto_migrate!
{% endhighlight %}

[DataMapper_Resource]:http://www.yardoc.org/docs/datamapper-dm-core/DataMapper/Resource
