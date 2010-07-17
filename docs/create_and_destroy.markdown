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

If you want to either find the first resource matching some given criteria or
just create that resource if it can't be found, you can use `#first_or_create`.

{% highlight ruby linenos %}
zoo = Zoo.first_or_create(:name => 'The Glue Factory')
{% endhighlight %}

This will first try to find a Zoo instance with the given name, and if it fails
to do so, it will return a newly created Zoo with that name.

If the criteria you want to use to query for the resource differ from the attributes
you need for creating a new resource, you can pass the attributes for creating a new
resource as the second parameter to `#first_or_create`, also in the form of a `#Hash`.

{% highlight ruby linenos %}
zoo = Zoo.first_or_create({ :name => 'The Glue Factory' }, { :inception => Time.now })
{% endhighlight %}

This will search for a Zoo named 'The Glue Factory' and if it can't find one, it will
return a new Zoo instance with it's name set to 'The Glue Factory' and the inception
set to what has been Time.now at the time of execution. You can see that for creating
a new resource, both hash arguments will be merged so you don't need to specify the
query criteria again in the second argument `Hash` that lists the attributes for creating
a new resource. However, if you really need to create the new resource with different values
from those used to query for it, the second `Hash` argument will overwrite the first one.

{% highlight ruby linenos %}
zoo = Zoo.first_or_create({ :name => 'The Glue Factory' }, {
  :name      => 'Brooklyn Zoo',
  :inception => Time.now
})
{% endhighlight %}

This will search for a Zoo named 'The Glue Factory' but if it fails to find one, it will
return a Zoo instance with its name set to 'Brooklyn Zoo' and its inception set to the
value of Time.now at execution time.

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

Just like `#create` has an accompanying `#first_or_create` method, `#new` has its
`#first_or_new` counterpart as well. The only difference with `#first_or_new` is that
it returns a new _unsaved_ resource in case it couldn't find one for the given query
criteria. Apart from that, `#first_or_new` behaves just like `#first_or_create` and
accepts the same parameters. For a detailed explanation of the arguments these two methods
accept, have a look at the explanation of `#first_or_create` in the above section on _Create_.

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
