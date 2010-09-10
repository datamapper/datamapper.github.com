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

  belongs_to :post # defaults to :required => true

  def self.popular
    all(:rating.gt => 3)
  end
end
{% endhighlight %}

The `belongs_to` method accepts a few options. As we already saw in the example
above, `belongs_to` relationships will be required by default (the parent resource
must exist in order for the child to be valid). You can make the parent resource
optional by passing `:required => false` as an option to `belongs_to`.

If the relationship makes up (part of) the key of a model, you can tell DM to
include it as part of the primary key by adding the `:key => true` option.

### has n, :through (or One-To-Many-Through)

{% highlight ruby linenos %}
class Photo
  include DataMapper::Resource
  property :id, Serial

  has n, :taggings
  has n, :tags, :through => :taggings
end

class Tag
  include DataMapper::Resource
  property :id, Serial

  has n, :taggings
  has n, :photos, :through => :taggings
end

class Tagging
  include DataMapper::Resource

  belongs_to :tag,   :key => true
  belongs_to :photo, :key => true
end

{% endhighlight %}

### Has, and belongs to, many (Or Many-To-Many)

The use of Resource in place of a class name tells DataMapper to use an
anonymous resource to link the two models up.

{% highlight ruby linenos %}
# When auto_migrate! is being called, the following model
# definitions will create an
#
#  ArticleCategory
#
# model that will be automigrated and that will act as the join
# model. DataMapper just picks both model names, sorts them
# alphabetically and then joins them together. The resulting
# storage name follows the same conventions it would if the
# model had been declared traditionally.
#
# The resulting model is no different from any traditionally
# declared model. It contains two belongs_to relationships
# pointing to both Article and Category, and both underlying
# child key properties form the composite primary key (CPK)
# of that model. DataMapper uses consistent naming conventions
# to infer the names of the child key properties. Since it's
# told to link together an Article and a Category model, it'll
# establish the following relationships in the join model.
#
#  ArticleCategory.belongs_to :article,  'Article',  :key => true
#  ArticleCategory.belongs_to :category, 'Category', :key => true
#
# Since every many to many relationship needs a one to many
# relationship to "go through", these also get set up for us.
#
#  Article.has n, :article_categories
#  Category.has n, article_categories
#
# Essentially, you can think of ":through => Resource" being
# replaced with ":through => :article_categories" when DM
# processes the relationship definition.
#
# This also means that you can access the join model just like
# any other DataMapper model since there's really no difference
# at all. All you need to know is the inferred name, then you can
# treat it just like any other DataMapper model.

class Article
  include DataMapper::Resource

  property :id, Serial

  has n, :categories, :through => Resource
end

class Category
  include DataMapper::Resource

  property :id, Serial

  has n, :articles, :through => Resource
end

# create two resources
article  = Article.create
category = Category.create

# link them by adding to the relationship
article.categories << category
article.save

# link them by creating the join resource directly
ArticleCategory.create(:article => article, :category => category)

# unlink them by destroying the related join resource
link = article.article_categories.first(:category => category)
link.destroy

# unlink them by destroying the join resource directly
link = ArticleCategory.get(article.id, category.id)
link.destroy
{% endhighlight %}

Self referential many to many relationships
-------------------------------------------

Sometimes you need to establish self referential relationships where both sides of the
relationship are of the same model. The canonical example seems to be the declaration of
a _Friendship_ relationship between two people. Here's how you would do that with DataMapper.

{% highlight ruby linenos %}
class Person
  include DataMapper::Resource
  property :id,    Serial
  property :name , String, :required => true
  has n, :friendships, :child_key => [:source_id]
  has n, :friends, self, :through => :friendships, :via => :target
end

class Friendship
  include DataMapper::Resource
  belongs_to :source, 'Person', :key => true
  belongs_to :target, 'Person', :key => true
end
{% endhighlight %}


The `Person` and `Friendship` model definitions look pretty straightforward at a first glance.
Every `Person` has an _id_ and a _name_, and a `Friendship` points to two instances of `Person`.

The interesting part are the relationship definitions in the `Person` model. Since we're modelling
friendships, we want to be able to get at one person's friends with one single method call. First,
we need to establish a _one to many_ relationship to the `Friendship` model.

{% highlight ruby linenos %}
class Person

  # ...

  # Since the foreign key pointing to Person isn't named 'person_id',
  # we need to override it by specifying the :child_key option. If the
  # Person model's key would be something different from 'id', we would
  # also need to specify the :parent_key option.

  has n, :friendships, :child_key => [:source_id]

end
{% endhighlight %}

This only gets us half the way though. We can now reach associated `Friendship` instances by traversing
`person.friendships`. However, we want to get at the actual _friends_, the instances of `Person`. We already
know that we can _go through_ other relationships in order to be able to construct _many to many_ relationships.

So what we need to do is to _go through_ the friendship relationship to get at the actual friends. To
achieve that, we have to tweak various options of that _many to many_ relationship definition.

{% highlight ruby linenos %}
class Person

  # ...

  has n, :friendships, :child_key => [:source_id]

  # We name the relationship :friends cause that's the original intention
  #
  # The target model of this relationship will be the Person model as well,
  # so we can just pass self where DataMapper expects the target model
  # You can also use Person or 'Person' in place of self here. If you're
  # constructing the options programmatically, you might even want to pass
  # the target model using the :model option instead of the 3rd parameter.
  #
  # We "go through" the :friendship relationship in order to get at the actual
  # friends. Since we named our relationship :friends, DataMapper assumes
  # that the Friendship model contains a :friend relationship. Since this
  # is not the case in our example, because we've named the relationship
  # pointing to the actual friend person :target, we have to tell DataMapper
  # to use that relationship instead, when looking for the relationship to
  # piggy back on. We do so by passing the :via option with our :target

  has n, :friends, self, :through => :friendships, :via => :target

end
{% endhighlight %}

Adding To Associations
----------------------

Adding resources to _many to one_ or _one to one_ relationships is as simple as
assigning them to their respective writer methods. The following example shows how
to assign a target resource to both a _many to one_ and a _one to one_ relationship.

{% highlight ruby linenos %}
class Person
  include DataMapper::Resource
  has 1, :profile
end

class Profile
  include DataMapper::Resource
  belongs_to :person
end

# Assigning a resource to a one-to-one relationship

person  = Person.create
person.profile = Profile.new
person.save

# Assigning a resource to a many-to-one relationship

profile = Profile.new
profile.person = Person.create
profile.save
{% endhighlight %}


Adding resources to any _one to many_ or _many to many_ relationship, can basically
be done in two different ways. If you don't have the resource already, but only have
a hash of attributes, you can either call the `new` or the `create` method directly
on the association, passing it the attributes in form of a hash.

{% highlight ruby linenos %}
post = Post.get(1) # find a post to add a comment to

# This will add a new but not yet saved comment to the collection
comment = post.comments.new(:subject => 'DataMapper ...')

# Both of the following calls will actually save the comment
post.save    # This will save the post along with the newly added comment
comment.save # This will only save the comment

# This will create a comment, save it, and add it to the collection
comment = post.comments.create(:subject => 'DataMapper ...')
{% endhighlight %}

If you already have an existing `Comment` instance handy, you can just append that
to the association using the `<<` method. You still need to manually save the parent
resource to persist the comment as part of the related collection.

{% highlight ruby linenos %}
post.comments << comment # append an already existing comment

# Both of the following calls will actually save the comment
post.save          # This will save the post along with the newly added comment
post.comments.save # This will only save the comments collection
{% endhighlight %}

Customizing Associations
------------------------

The association declarations make certain assumptions about the names of foreign keys
and about which classes are being related. They do so based on some simple conventions.

The following two simple models will explain these default conventions in detail, showing
relationship definitions that solely rely on those conventions. Then the same relationship
definitions will be presented again, this time using all the available options explicitly.
These additional versions of the respective relationship definitions will have the exact same
effect as their simpler counterparts. They are only presented to show which options can be
used to customize various aspects when defining relationships.

{% highlight ruby linenos %}
class Blog

  include DataMapper::Resource

  # The rules described below apply equally to definitions
  # of one-to-one relationships. The only difference being
  # that those would obviously only point to a single resource.

  # However, many-to-many relationships don't accept all the
  # options described below. They do support specifying the
  # target model, like we will see below, but they do not support
  # the :parent_key and the :child_key options. Instead, they
  # support another option that's available to many-to-many
  # relationships exclusively. This option is called :via, and
  # will be explained in more detail in its own paragraph below.

  # - This relationship points to multiple resources
  # - The target resources will be instances of the 'Post' model
  # - The local parent_key is assumed to be 'id'
  # - The remote child_key is assumed to be 'blog_id'
  #   - If the child model (Post) doesn't define the 'blog_id'
  #     child key property either explicitly, or implicitly by
  #     defining it using a belongs_to relationship, it will be
  #     established automatically, using the defaults described
  #     here ('blog_id').

  has n, :posts

  # The following relationship definition has the exact same
  # effect as the version above. It's only here to show which
  # options control the default behavior outlined above.

  has n, :posts, 'Post',
    :parent_key => [:id],      # local to this model (Blog)
    :child_key  => [:blog_id]  # in the remote model (Post)

end

class Post

  include DataMapper::Resource

  # - This relationship points to a single resource
  # - The target resource will be an instance of the 'Blog' model
  # - The locally established child key will be named 'blog_id'
  #   - If a child key property named 'blog_id' is already defined
  #     for this model, then that will be used.
  #   - If no child key property named 'blog_id' is already defined
  #     for this model, then it gets defined automatically.
  # - The remote parent_key is assumed to be 'id'
  #   - The parent key must be (part of) the remote model's key
  # - The child key is required to be present
  #   - A parent resource must exist and be assigned, in order
  #     for this resource to be considered complete / valid

  belongs_to :blog

  # The following relationship definition has the exact same
  # effect as the version above. It's only here to show which
  # options control the default behavior outlined above.
  #
  # When providing customized :parent_key and :child_key options,
  # it is not necessary to specify both :parent_key and :child_key
  # if only one of them differs from the default conventions.
  #
  # The :parent_key and :child_key options both accept arrays
  # of property name symbols. These should be the names of
  # properties being (at least part of) a key in either the
  # remote (:parent_key) or the local (:child_key) model.
  #
  # If the parent resource need not be present in order for this
  # model to be considered complete, :required => false can be
  # passed to stop DataMapper from establishing checks for the
  # presence of the attribute value.

  belongs_to :blog, 'Blog',
    :parent_key => [:id],      # in the remote model (Blog)
    :child_key  => [:blog_id], # local to this model (Post)
    :required   => true        # the blog_id must be present

end
{% endhighlight %}

In addition to the `:parent_key` and `:child_key` options that we just saw,
the `belongs_to` method also accepts the `:key` option. If a `belongs_to`
relationship is marked with `:key => true`, it will either form the complete
primary key for that model, or it will be part of the primary key. The latter
will be the case if other properties or `belongs_to` definitions have been
marked with `:key => true` too, to form a composite primary key (_CPK_).
Marking a `belongs_to` relationship or any `property` with `:key => true`,
automatically makes it `:required => true` as well.

{% highlight ruby linenos %}
class Post
  include DataMapper::Resource
  belongs_to :blog, :key => true # 'blog_id' is the primary key
end

class Person
  include DataMapper::Resource
  property id, Serial
end

class Authorship

  include DataMapper::Resource

  belongs_to :post,   :key => true # 'post_id'   is part of the CPK
  belongs_to :person, :key => true # 'person_id' is part of the CPK

end
{% endhighlight %}

When defining _many to many_ relationships you may find that you need to
customize the relationship that is used to "go through". This can be particularly
handy when defining self referential many-to-many relationships like we saw above.
In order to change the relationship used to "go through", DataMapper allows us to
specifiy the `:via` option on _many to many_ relationships.

The following example shows a scenario where we don't use `:via` for defining
_self referential many to many_ relationships. Instead, we will use `:via` to be
able to provide "better" names for use in our domain models.

{% highlight ruby linenos %}
class Post

  include DataMapper::Resource

  property :id, Serial

  has n, :authorships

  # Without the use of :via here, DataMapper would
  # search for an :author relationship in Authorship.
  # Since there is no such relationship, that would
  # fail. By using :via => :person, we can instruct
  # DataMapper to use that relationship instead of
  # the :author default.

  has n, :authors, 'Person',
    :through => :authorships,
    :via     => :person

end

class Person
  include DataMapper::Resource
  property id, Serial
end

class Authorship

  include DataMapper::Resource

  belongs_to :post,   :key => true # 'post_id'   is part of the CPK
  belongs_to :person, :key => true # 'person_id' is part of the CPK

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

Querying via Relationships
--------------------------

Sometimes it's desirable to query based on relationships.  DataMapper makes this
as easy as passing a hash into the query conditions:

{% highlight ruby linenos %}
# find all Posts with a Comment by the user
Post.all(:comments => { :user => @user })
# in SQL => SELECT * FROM "posts" WHERE "id" IN
#     (SELECT "post_id" FROM "comments" WHERE "user_id" = 1)

# This also works (which you can use to build complex queries easily)
Post.all(:comments => Comment.all(:user => @user))
# in SQL => SELECT * FROM "posts" WHERE "id" IN
#     (SELECT "post_id" FROM "comments" WHERE "user_id" = 1)

# Of course, it works the other way, too
# find all Comments on posts with DataMapper in the title
Comment.all(:post => { :title.like => '%DataMapper%' })
# in SQL => SELECT * from "comments" WHERE "post_id" IN
#     (SELECT "id" FROM "posts" WHERE "title" LIKE '%DataMapper%')
{% endhighlight %}

DataMapper accomplishes this (in sql data-stores, anyway) by turning the queries
across relationships into sub-queries.
