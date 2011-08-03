---
layout:     default
title:      Hooks (AKA Callbacks)
body_id:    docs
created_at: Fri Nov 30 15:29:01 +1030 2007
---

{{ page.title }}
================

You can define callbacks for any of the model's explicit lifecycle events:

* `create`
* `update`
* `save`
* `destroy`

Currently, `valid?` is not yet included in this list but it could be
argued that validation is important enough to make it an explicit
lifecycle event. Future versions of DataMapper will most likely include
`valid?` in the list of explicit lifecycle events.

If you need to hook any of the non-lifecycle methods, DataMapper still
has you covered tho. It's also possible to declare advice for any other
method on both class and instance level. Hooking instance methods can be
done using `before` or `after` as described below. In order to hook
class methods you can use `before_class_method` and `after_class_method`
respectively. Both take the same options as their instance level
counterparts.

However, hooking non-lifecycle methods will be deprecated in future versions
of DataMapper, which will only provide hooks for the explict lifecycle events.
Users will then be advised to either roll their own hook system or use any of
the available gems that offer that kind of functionality.

Adding callbacks
----------------------------

To declare a callback for a specific lifecycle event, define a new method to
be run when the event is raised, then define your point-cut.

{% highlight ruby linenos %}
class Post
  include DataMapper::Resource

  # key and properties here

  before :save, :categorize

  def categorize
    # code here
  end
end
{% endhighlight %}

Alternatively, you can declare the advice during the point-cut by supplying a
block rather than a symbol representing a method.

{% highlight ruby linenos %}
class Post
  include DataMapper::Resource

  # key and properties here

  before :save do
    # code here
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
