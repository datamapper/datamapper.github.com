---
layout:     default
title:      Hooks (AKA Callbacks)
body_id:    docs
created_at: Fri Nov 30 15:29:01 +1030 2007
---

{{ page.title }}
================

DataMapper supports callbacks using an [aspect-oriented approach](http://en.wikipedia.org/wiki/Aspect_oriented).
You can define callbacks for any of the model events: create, update, save, and destroy.

Note: previously it was possible to declare advice for any method.  This is being deprecated in future versions of DataMapper.

Adding callbacks
----------------------------

To declare a callback (advice) for a specific event, first define a new method to
be run when the event is raised, then define your point-cut.

{% highlight ruby linenos %}
class Post
  include DataMapper::Resource

  # ... key and properties here

  before :save, :categorize

  def categorize
    # ... code here
  end
end
{% endhighlight %}

Alternatively, you can declare the advice during the point-cut by supplying a
block rather than a symbol representing a method.

{% highlight ruby linenos %}
class Post
  include DataMapper::Resource

  # ... key and properties here

  before :save do
    # ... code here
  end
end
{% endhighlight %}

Throw :halt, in the name of love...
-----------------------------------

In order to abort advice and prevent the advised method from being called, throw `:halt`

{% highlight ruby linenos %}
class Post
  include DataMapper::Resource

  # ... key and properties here

  # This record will save properly
  before :save do |post|
    true
  end

  # But it will not be destroyed
  before :destroy do |post|
    throw :halt
  end
end
{% endhighlight %}

Remember, if you `throw :halt` inside an `after` advice, the advised method will
have already ran and returned. Because of this, the `after` advice will be the
only thing halted.
