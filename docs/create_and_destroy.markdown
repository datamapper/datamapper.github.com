---
layout:     default
title:      Create, Update, Save and Destroy
body_id:    docs
created_at: Tue Dec 04 14:46:32 +1030 2007
---

{{ page.title }}
================

To illustrate the various methods used in manipulating records, we'll create,
save and destroy a record.

{% highlight ruby linenos %}
class Zoo
  include DataMapper::Resource

  property :id,          Serial
  property :name,        String
  property :description, Text
  property :inception,   DateTime
  property :open,        Boolean,  :default => false
end
{% endhighlight %}

Creating
--------

Let's create a new instance of the model, update its properties and save it to
the data store. Save will return true if the save succeeds, or false when
something went wrong.

{% highlight ruby linenos %}
zoo = Zoo.new
zoo.attributes = { :name => 'The Glue Factory', :inception => Time.now }
zoo.save
{% endhighlight %}

Pretty straight forward. In this example we've updated the attributes using the
`#attributes=` method, but there are multiple ways of setting the values of a
model's properties.

{% highlight ruby linenos %}
zoo = Zoo.new(:name => 'Awesome Town Zoo')                  # Pass in a hash to the new method
zoo.name = 'Dodgy Town Zoo'                                 # Set individual property
zoo.attributes = { :name => 'No Fun Zoo', :open => false }  # Set multiple properties at once
{% endhighlight %}

You can also update a model's properties and save it with one method call.
`#update` will return true if the record saves, false if the save fails, exactly
like the `#save` method.

{% highlight ruby linenos %}
zoo.update(:name => 'Funky Town Municipal Zoo')
{% endhighlight %}

If you want to create a new resource with some given attributes, and save it in one go,
you can use the `#create` method.

{% highlight ruby linenos %}
zoo = Zoo.create(:name => 'The Glue Factory', :inception => Time.now)
{% endhighlight %}

Internally it will call `#new` and then `#save` just like we did before.
If the creation was successful, `#create` will return the newly created
`#DataMapper::Resource`. If it failed, it will return `nil` instead.

Destroy
-------

To destroy a record, you simply call it's `#destroy!` method. It will return
true or false depending if the record is successfully deleted. Here is an
example of finding an existing record then destroying it.

{% highlight ruby linenos %}
zoo = Zoo.get(5)
zoo.destroy! #=> true
{% endhighlight %}
