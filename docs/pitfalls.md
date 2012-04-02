---
layout: default
title: Common Pitfalls
body_id: docs
created_at: Sun Apr 01 21:13:13 -0700 2012
---

{{ page.title }}
================

Below is a list of common problems that someone new to DataMapper will
encounter, along with work-arounds or solutions if possible.

Implicit String property length
-------------------------------

When declaring a String property, DataMapper will add an implicit limit of 50
characters if no limit is explicitly declared.

For example, the two class declarations have identical behaviour:
{% highlight ruby linenos %}
# with an implicit length
class Post
  include DataMapper::Resource

  property :title, String
end

# with an explicit length
class Post
  include DataMapper::Resource

  property :title, String, :length => 50
end
{% endhighlight %}
The reason for this default is that DataMapper needs to know the underlying
column constraints in order to add validations from the property definitions.
Databases will often choose their own arbitrary length constraints if one is not
declared (often defaulting to 255 chars). We choose something a bit more
restrictive as a default because we wanted to encourage peolpe to declare
it explicitly in their model, rather than relying on DM or the DB choosing
an arbitrary limit.
