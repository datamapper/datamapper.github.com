---
layout:     default
title:      Create, Save, Update and Destroy
body_id:    docs
created_at: Tue Dec 04 14:46:32 +1030 2007
---

{{ page.title }}
================

To illustrate the various methods used in manipulating records, we'll create,
save, update and destroy a record.

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

Create
------

If you want to create a new resource with some given attributes and then
save it all in one go, you can use the `#create` method.

{% highlight ruby linenos %}
zoo = Zoo.create(:name => 'The Glue Factory', :inception => Time.now)
{% endhighlight %}

If the creation was successful, `#create` will return the newly created
`DataMapper::Resource`. If it failed, it will return a new resource that
is initialized with the given attributes and possible default values declared
for that resource, but that's not yet saved. To find out wether the creation
was successful or not, you can call `#saved?` on the returned resource. It will
return `true` if the resource was successfully persisted, or `false` otherwise.

{% highlight ruby linenos %}
zoo = Zoo.create(:name => 'The Glue Factory', :inception => Time.now)
{% endhighlight %}

Save
----

We can also create a new instance of the model, update its properties and then
save it to the data store. The call to `#save` will return `true` if saving succeeds,
or `false` in case something went wrong.

{% highlight ruby linenos %}
zoo = Zoo.new
zoo.attributes = { :name => 'The Glue Factory', :inception => Time.now }
zoo.save
{% endhighlight %}

In this example we've updated the attributes using the `#attributes=` method,
but there are multiple ways of setting the values of a model's properties.

{% highlight ruby linenos %}
zoo = Zoo.new(:name => 'Awesome Town Zoo')                  # Pass in a hash to the new method
zoo.name = 'Dodgy Town Zoo'                                 # Set individual property
zoo.attributes = { :name => 'No Fun Zoo', :open => false }  # Set multiple properties at once
{% endhighlight %}

Update
------

You can also update a model's properties and save it with one method call.
`#update` will return `true` if the record saves and `false` if the save fails,
exactly like the `#save` method.

{% highlight ruby linenos %}
zoo.update(:name => 'Funky Town Municipal Zoo')
{% endhighlight %}

One thing to note is that the `#update` method refuses to update a resource
in case the resource itself is `#dirty?` at this time.

{% highlight ruby linenos %}
zoo.name = 'Brooklyn Zoo'
zoo.update(:name => 'Funky Town Municipal Zoo')
# => DataMapper::UpdateConflictError: Zoo#update cannot be called on a dirty resource
{% endhighlight %}

Destroy
-------

To destroy a record, you simply call it's `#destroy!` method. It will return
`true` or `false` depending if the record is successfully deleted or not. Here
is an example of finding an existing record then destroying it.

{% highlight ruby linenos %}
zoo = Zoo.get(5)
zoo.destroy! #=> true
{% endhighlight %}

Raising an exception when save fails
------------------------------------

By default, datamapper returns `true` or `false` for all operations manipulating
the persisted state of a resource (`#create`, `#save`, `#update` and `#destroy`).

If you want it to raise exceptions instead, you can instruct datamapper to do so
either globally, on a per-model, or on a per-instance basis.

{% highlight ruby linenos %}
DataMapper::Model.raise_on_save_failure = true # globally
Zoo.raise_on_save_failure = true               # per-model
zoo.raise_on_save_failure = true               # per-instance
{% endhighlight %}
