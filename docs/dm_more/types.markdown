---
layout:     default
title:      DM-Types
created_at: 2008-09-06 18:30:16.740699 +01:00
---

{{ page.title }}
================

Types are used by DataMapper to map ruby objects into values in the data-store
on saving and to translate the values back into ruby objects when a resource is
retrieved. The core library supplies several different types, providing mappings
for most of the simple ruby objects as direct values in the data-store as well
as the Object type which can store any Marshallable ruby object.

They're intended to make the storage of ruby objects as transparent as possible,
no matter what the ruby object is, or which data-store is used as the backend.

dm-types
--------

In [DM More](/docs/dm_more) there is the dm-types gem, which supplies several
more types that map less common ruby classes to data-store values or take care
of serializing them to text based formats.

### Enum

The Enum type uses an Integer create a property which can take one of a number
of symbolic values. A use for this might be bug status for an issue tracker or
the protocol being used in a packet logging application.

{% highlight ruby linenos %}
class Issue
  include DataMapper::Resource

  property :status, Enum[ :new, :open, :closed, :invalid ], :default => :new
  # other properties ...
end

@i = Issue.new
@i.status
# => :new
@i.status = :open
# => :open
{% endhighlight %}

### Flag

A Flag is similar to an Enum, though the property that is created can hold
multiple symbol values at once. This could be used for recording which colours a
product can be ordered in, or what extra features an account has enabled.

{% highlight ruby linenos %}
class Widget
  include DataMapper::Resource

  property :colours, Flag[ :red, :green, :blue, :heliotrope ]

  # other properties ...
end

@w = Widget.new
@w.colours = [ :red, :heliotrope ]
{% endhighlight %}

### Object Mappings

These map objects into simple data-store primitives, then re-initialize as the
ruby types

EpochTime
: A ruby Time object stored in the data-store as an Integer -- the number of
  seconds since the UNIX epoch.

URI
: A ruby URI object, pre-parsed for use of methods such as `#params` or `#uri`,
  stored as a string in the data-store.

FilePath
: Stored as a string in the data-store, FilePaths initialize Pathname objects,
  making it easy to perform various file operations on the file.

Regexp
: A ruby regex, stored as a string.

IPAddress
: Ruby IPAddr, stored as the string representation.

BCryptHash
: Stored in the data-store as string representing the salt, hash and cost of a
  password using OpenBSD's bcrypt algorithm, it offers an alternative to the
  more usual pair of hash and salt columns.

### Serializers

These store values in the data-store using text based serialization formats.
They work via calling dumping the object to the format on saving and parsing the
text to reinitialize them on loading.

* Csv
* Json
* Yaml

Writing Your Own
----------------

Writing your own custom type isn't difficult. There are two (or perhaps three)
methods to implement, as well as the selection of an appropriate primitive. All
types are a class which should descend from `DataMapper::Property::Object`.

### The Primitive

DataMapper offers several choices for a data-store primitive.

* Boolean
* Class
* Date
* DateTime
* BigDecimal
* Float
* Integer
* Float
* String
* Object
* Time

To assign a primitive to a type, either make the type descend from
`DataMapper::Property::(PrimitiveClass)` or within the class definition, use
`primitive PrimitiveClass`.

### dump

A type's `dump(value)` method is called when the object is saved
to the data-store. It is responsible for mapping whatever is assigned to the
property on to the primitive type. For example, the EpochTime Type saves an
integer directly to the data-store, or calls `to_i()` if a Time object is passed
to it.

### load

The `load(value)` method is called when the property is retrieved
from the data-store. It takes the primitive value and initializes a ruby object
from it. For example, the Json type performs `JSON.parse(value)` to convert the
json string back into appropriate ruby.

### typecast_to_primitive

Typecasting is provided by the types `typecast_to_primitive(value)` method,
which tries to coerce whatever value the property has into an appropriate type.
A type doesn't have to provide a typecast but it can be useful, for example to
allow the string '2008-09-06' to be converted to a ruby Date without having to
reload the model.

### Examples

For examples of the types, the best place to look is <a
href="http://github.com/datamapper/dm-types">dm-types</a> on
github.
