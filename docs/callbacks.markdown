---
layout:     default
title:      Hooks (AKA Callbacks)
body_id:    docs
created_at: Fri Nov 30 15:29:01 +1030 2007
---

{{ page.title }}
================

DataMapper supports callbacks using an [aspect-oriented approach](http://en.wikipedia.org/wiki/Aspect_oriented).
You can define callbacks for any method as well as any class method arbitrarily.

Adding Instance-Level Advice
----------------------------

To declare advice (callback) for a specific method, first define a new method to
be run when another is called, then define your point-cut.

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

Adding Class-Level Advice
-------------------------

To install advice around a class method, use `before_class_method` or `after_class_method`:

{% highlight ruby linenos %}
class Post
  include DataMapper::Resource

  # ... key and properties here

  before_class_method :find, :prepare

  def self.prepare
    # ... code here
  end
end
{% endhighlight %}

Class level advice does not have access to any resulting instances from the
class method, so they might not be the best fit for `after_create` or
`after_save`.

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
