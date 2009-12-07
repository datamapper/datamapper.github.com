---
layout:     default
title:      Associations
body_id:    docs
created_at: Tue Dec 04 14:46:32 +1030 2007
---

{{ page.title }}
================

Associations are a way of declaring relationships between models, for example a
blog Post "has many" Comments, or a Post belongs to an Author. They add a series
of methods to your models which allow you to create relationships and retrieve
related models along with a few other useful features. Which records are related
to which are determined by their foreign keys.

The types of associations currently in DataMapper are:

<table summary="Associations">
  <thead>
    <tr>
      <td>ActiveRecord Terminology</td>
      <td>DataMapper Terminology</td>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>has_many</td>
      <td>has n</td>
    </tr>
    <tr>
      <td>has_one</td>
      <td>has 1</td>
    </tr>
    <tr>
      <td>belongs_to</td>
      <td>belongs_to</td>
    </tr>
    <tr>
      <td>has_and_belongs_to_many</td>
      <td>has n, :things, :through => Resource</td>
    </tr>
    <tr>
      <td>has_many :association, :through => Model</td>
      <td>has n, :things, :through => :model</td>
    </tr>
  </tbody>
</table>

Declaring Associations
----------------------

This is done via declarations inside your model class. The class name of the
related model is determined by the symbol you pass in. For illustration, we'll
add an association of each type. Pay attention to the pluralization or the
related model's name.

### has n and belongs_to (or One-To-Many)

{% highlight ruby linenos %}
class Post
  include DataMapper::Resource

  property :id, Serial

  has n, :comments
end

class Comment
  include DataMapper::Resource

  property :id,     Serial
  property :rating, Integer

  belongs_to :post

  def self.popular
    all(:rating.gt => 3)
  end
end

{% endhighlight %}

### has n, :through (or One-To-Many-Through)

{% highlight ruby linenos %}
class Photo
  include DataMapper::Resource

  has n, :taggings
  has n, :tags, :through => :taggings
end

class Tag
  include DataMapper::Resource

  has n, :taggings
  has n, :photos, :through => :taggings
end

class Tagging
  include DataMapper::Resource

  belongs_to :tag
  belongs_to :photo
end

{% endhighlight %}

### Has, and belongs to, many (Or Many-To-Many)

{% highlight ruby linenos %}
class Article
  include DataMapper::Resource

  has n, :categories, :through => Resource
end

class Category
  include DataMapper::Resource

  has n, :articles, :through => Resource
end

{% endhighlight %}

The use of Resource in place of a class name tells DataMapper to use an
anonymous resource to link the two models up.

Adding To Associations
----------------------

Adding to associations, to add a comment to a post for example, is quite simple.
`build` or `create` can be called directly on the association, or an already
existing item can be appended to the association with `<<` and then the item
saved.

{% highlight ruby linenos %}
# Assume we set up comments and posts as before, as actual models.

# find a post to add a comment to
@post = Post.get(1)

# Add the comment
# (also #create can be used - it acts as Comment.create would)
@comment = @post.comments.new(:subject => 'DataMapper ...', ...)

# and save it
@comment.save


# Or if we already have a comment ...

# append it to the comments
@post.comments << @comment

# and save.
@post.save
{% endhighlight %}

Customizing Associations
------------------------

The association declarations make certain assumptions about which classes are
being related and the names of foreign keys based on some simple conventions. In
some situations you may need to tweak them a little. The association
declarations accept additional options to allow you to customize them as you
need

{% highlight ruby linenos %}
class Post
  include DataMapper::Resource

  belongs_to :author, :model => 'User', :child_key => [ :post_id ]
end
{% endhighlight %}

Adding Conditions to Associations
---------------------------------

If you want to order the association, or supply a scope, you can just pass in
the options...

{% highlight ruby linenos %}
class Post
  include DataMapper::Resource

  has n, :comments, :order => [ :published_on.desc ], :rating.gte => 5
  # Post#comments will now be ordered by published_on, and filtered by rating > 5.
end
{% endhighlight %}

Finders off Associations
------------------------

When you call an association off of a model, internally DataMapper creates a
Query object which it then executes when you start iterating or call `length`
off of. But if you instead call `.all` or `.first` off of the association and
provide it the exact same arguments as a regular `all` and `first`, it merges
the new query with the query from the association and hands you back a requested
subset of the association's query results.

In a way, it acts like a database view in that respect.

{% highlight ruby linenos %}
@post = Post.first
@post.comments # returns the full association
@post.comments.all(:limit => 10, :order => [ :created_at.desc ]) # return the first 10 comments, newest first
@post.comments(:limit => 10, :order => [ :created_at.desc ]) # alias for #all, you can pass in the options directly
@post.comments.popular # Uses the 'popular' finder method/scope to return only highly rated comments
{% endhighlight %}
