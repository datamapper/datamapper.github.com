---
layout:       spotlight
categories:   articles
title:        Spotlight on... Composite Keys
created_at:   2008-03-29T19:09:07-05:00
summary:      When a Primary Key Just Isn't Enough
author:       afrench and ssmoot
---

{{ page.title }}
================

For those of us who have taken a course on database design in college or
university, you may have run across a concept called 'Composite Primary Keys'
(or sometimes 'Compound Keys' or 'Concatenated Keys', and abbreviated CPKs).
It's usually right before you tackle JOINs and right after you fight with the
"surrogate key" or "primary key" concept.

Boiling CPKs down, they're just a way of identifying a row by multiple keys
rather than one. So instead of an auto_incrementing "serial" primary key (as in
`id`), you'd have a combination of `some_column` and `some_other_column` that
would uniquely identify a row.

CPKs aren't as prevalent in the Rails world as Serial Keys (such as the
auto-incrementing `:id` column), but if you're going to support legacy,
integration or reporting databases or just de-normalized schemas for performance
reasons, they can be invaluable. So sure, Surrogate Keys are a great
convenience, but sometimes they just aren't an option.

Let's briefly take a look at how a few ruby ORMs support Composite Primary Keys
and then we'll talk about DataMapper's support for CPKs.

ActiveRecord
------------

In short, ActiveRecord doesn't support CPKs without the help of an external
library. [Dr. Nic Williams](http://drnicwilliams.com/about/)
[Composite Keys](http://compositekeys.rubyforge.org/) is an effort to overcome
this limitation.

Sequel
------

Unlike ActiveRecord, Sequel supports CPKs natively:

{% highlight ruby linenos %}
class Post < Sequel::Model
  set_primary_key [ :category, :title ]
end

post = Post.get('ruby', 'hello world')
post.key  # => [ 'ruby', 'hello world' ]
{% endhighlight %}

p(attribution). example compiled from <http://github.com/jeremyevans/sequel>.

DataMapper
----------

The latest DataMapper was designed from the ground up to support CPKs:

{% highlight ruby linenos %}
class Pig
  include DataMapper::Resource

  property :id,   Integer, :key => true
  property :slug, String,  :key => true
  property :name, String
end

pig = Pig.get(1, 'Porky')

pig.key  # => [ 1, 'Wilbur' ]
{% endhighlight %}

We declared our keys by adding the `:key => true` to the appropriate properties.
The order is important as it will determine the order keys are addressed
throughout the system.

Next, we mixed and matched the keys' types. `:id` is a Integer, but `:slug` is a
String. DataMapper didn't flinch when we defined a key column as a String
because it supports [Natural Keys](http://en.wikipedia.org/wiki/Natural_key) as
well.

Lastly, when retrieving rows via `get` and `[]` with a CPK, we supplied the keys
in the order they were defined within our model. For example, we defined `:id`
first, then `:slug` second; later, we retrieved Porky by specifying his `:id`
and `:slug` in the same order. Additionally, when we asked Wilbur for his keys,
he handed us an array in the order the keys were defined.

We didn't need to mix in an external library to get support for CPKs, nor did we
need to call a `set_primary_key` method and then supply more than one key to it.
DataMapper supports Composite Primary Keys intuitively and without compromise!

In later "Spotlight On..." articles, we'll examine and demonstrate other
DataMapper features or persistence concepts as well as compare similar features
with other ORMs or libraries.

*[CPK]: Composite Primary Keys
