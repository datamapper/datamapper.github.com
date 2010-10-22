---
layout:     default
title:      Properties
body_id:    docs
created_at: Tue Dec 04 13:27:16 +1030 2007
---

<%= @item[:title] %>
================

A model's properties are not introspected from the fields in the data-store; In
fact the reverse happens. You declare the properties for a model inside it's
class definition, which is then used to generate the fields in the data-store.

This has a few advantages. First it means that a model's properties are
documented in the model itself, not a migration or XML file. If you've ever been
annoyed at having to look in a schema file to see the list of properties and
types for a model, you'll find this particularly useful. There's no need for a
special `annotate` rake task either.

Second, it lets you limit access to properties using Ruby's access semantics.
Properties can be declared public, private or protected. They are public by
default.

Finally, since DataMapper only cares about properties explicitly defined in your
models, DataMapper plays well with legacy data-stores and shares them easily
with other applications.

Declaring Properties
--------------------

Inside your class, call the property method for each property you want to add.
The only two required arguments are the name and type, everything else is
optional.

<pre><code class="language-ruby">
class Post
  include DataMapper::Resource

  property :id,        Serial                       # primary serial key
  property :title,     String,  :required => true   # Cannot be nil
  property :published, Boolean, :default  => false  # Default value for new records is false
end
</code></pre>

Keys
----

### Primary Keys

Primary keys are not automatically created for you, as with ActiveRecord. You
MUST configure at least one key property on your data-store. More often than
not, you'll want an auto-incrementing integer as a primary key, so DM has a
shortcut:

<pre><code class="language-ruby">
  property :id, Serial
</code></pre>

### Natural Keys

Anything can be a key. Just pass `:key => true` as an option during the property
definition. Most commonly, you'll see String as a natural key:

<pre><code class="language-ruby">
  property :slug, String, :key => true  # any Type is available here
</code></pre>

Natural Keys are protected against mass-assignment, so their `setter=` will need
to be called individually if your looking to set them.

*Fair warning:* Using Boolean, Discriminator, and the time related types as keys
may cause your DBA to hunt you down and "educate" you. DM will not be held
responsible for any injuries or death that may result.

### Composite Keys

You can have more than one property in the primary key:

<pre><code class="language-ruby">
class Post
  include DataMapper::Resource

  property :old_id, Integer, :key => true
  property :new_id, Integer, :key => true
end
</code></pre>

Setting default values
----------------------

Defaults can be set via the `:default` key for a property. They can be static
values, such as `12` or `"Hello"`, but DataMapper also offers the ability to use
a Proc to set the default value. The property becomes whatever the Proc returns,
which will be called the first time the property is used without having first
set a value. The Proc itself receives two arguments: The resource the property
is being set on, and the property itself.

<pre><code class="language-ruby">
class Image
  include DataMapper::Resource

  property :id,     Serial
  property :path,   FilePath, :required => true
  property :md5sum, String,   :length => 32, :default => lambda { |r, p| Digest::MD5.hexdigest(r.path.read) if r.path }
end
</code></pre>

When creating the resource, or the first time the `md5sum` property is accessed,
it will be set to the hex digest of the file referred to by `path`.

*Fair Warning*: A property default must _not_ refer to the value of the property
it is about to set, or there will be an infinite loop.

Setting default options
-----------------------

If you find that you're setting the same default options over and over
again, you can specify them once and have them applied to all properties
you add to your models.

{% highlight ruby linenos %}
# set all String properties to have a default length of 255
DataMapper::Property::String.length(255)

# set all Boolean properties to not allow nil (force true or false)
DataMapper::Property::Boolean.allow_nil(false)

# set all properties to be required by default
DataMapper::Property.required(true)

# turn off auto-validation for all properties by default
DataMapper::Property.auto_validation(false)

# set all mutator methods to be private by default
DataMapper::Property.writer(false)
{% endhighlight %}

Please note that this currently has the unfortunate side effect of not
allowing subclasses to define their own option values. For example,
setting the String length to 255 will affect the Text property even
though it inherits from String and sets it's own default length to 65535.
This is a [known bug](http://datamapper.lighthouseapp.com/projects/20609/tickets/1430)
and will be fixed in the next release (1.0.3).

You can of course still override these defaults by specifying any
option explicitly when defining a specific property.

Lazy Loading
------------

Properties can be configured to be lazy loaded. A lazily loaded property is not
requested from the data-store by default. Instead it is only loaded when it's
accessor is called for the first time. This means you can stop default queries
from being greedy, a particular problem with text fields. Text fields are lazily
loaded by default, which you can over-ride if you need to.

<pre><code class="language-ruby">
class Post
  include DataMapper::Resource

  property :id,    Serial
  property :title, String
  property :body,  Text                    # Is lazily loaded by default
  property :notes, Text,   :lazy => false  # Isn't lazy, will load by default
end
</code></pre>

Lazy Loading can also be done via contexts, which let you group lazily loaded
properties together, so that when one is fetched, all the associated ones will
be as well, cutting down on trips to the data-store.

<pre><code class="language-ruby">
class Post
  include DataMapper::Resource

  property :id,       Serial
  property :title,    String
  property :subtitle, String   :lazy => [ :show ]
  property :body,     Text     :lazy => [ :show ]
  property :views,    Integer, :lazy => [ :show ]
  property :summary,  Text
end
</code></pre>

In this example, only the title (and the id, of course) will be loaded from the
data-store on a `Post.all`. But as soon as the value for subtitle, body or
views are called, all three will be loaded at once, since they're members of the
`:show` group. The summary property on the other hand, will only be fetched when
it is asked for.

Available Types
---------------

DM-Core supports the following 'primitive' data-types.

* Boolean
* String
* Text
* Float
* Integer
* Decimal
* DateTime, Date, Time
* Object, (marshalled)
* Discriminator

If you include DM-Types, the following data-types are supported:

* BCryptHash
* CommaSeparatedList
* Csv
* Enum
* EpochTime
* FilePath
* Flag
* IPAddress
* Json
* ParanoidBoolean
* ParanoidDateTme
* Regexp
* Slug
* URI
* UUID
* Yaml

Limiting Access
---------------

Access for properties is defined using the same semantics as Ruby. Accessors are
public by default, but you can declare them as private or protected if you need
to. You can set access using the `:accessor` option. For demonstration, we'll
reopen our Post class.

<pre><code class="language-ruby">
class Post
  property :title, String, :accessor => :private    # Both reader and writer are private
  property :body,  Text,   :accessor => :protected  # Both reader and writer are protected
end
</code></pre>

You also have more fine grained control over how you declare access. You can,
for example, have a public reader and private writer by using the `:writer` and
`:reader` options. (Remember, the default is Public)

<pre><code class="language-ruby">
class Post
  property :title, String, :writer => :private    # Only writer is private
  property :tags,  String, :reader => :protected  # Only reader is protected
end
</code></pre>

Over-riding Accessors
---------------------

When a property has declared accessors for getting and setting, it's values are
added to the model. Just like using `attr_accessor`, you can over-ride these
with your own custom accessors. It's a simple matter of adding an accessor after
the property declaration. Reopening the Post class....

<pre><code class="language-ruby">
class Post
  property :slug, String

  def slug=(new_slug)
    raise ArgumentError if new_slug != 'DataMapper is Awesome'
    super  # use original method instead of accessing @ivar directly
  end
end
</code></pre>
