---
layout:     default
title:      Create, Save, Update and Destroy
body_id:    docs
created_at: Tue Dec 04 14:46:32 +1030 2007
---

{{ page.title }}
================

This page describes the basic methods to use when creating, saving, updating and destroying
resources with DataMapper. Some of DataMapper's concepts might be confusing to users coming
from ActiveRecord for example. For this reason, we start with a little background on the usage
of bang vs. no-bang methods in DataMapper, followed by ways of manipulating the rules DataMapper
abides when it comes to raising exceptions in case some persistence operation went wrong.

Bang(!) or no bang methods
-----------------------------

This page is about creating, saving, updating and destroying resources with
DataMapper. The main methods to achieve these tasks are `#create`, `#save`,
`#update` and `#destroy`. All of these methods have _bang method equivalents_
which operate in a slightly different manner. DataMapper follows the general
ruby idiom when it comes to using bang or non-bang methods. A detailed explanation
of this idiom can be found at

[David A. Black's weblog](http://dablog.rubypal.com/2007/8/15/bang-methods-or-danger-will-rubyist)

When you call a non-bang method like `#save`, DataMapper will _invoke all callbacks_
defined for resources of the model. This means that it will have to _load all affected
resources into memory_ in order to be able to execute the callbacks on each one of them.
This can be considered the _safe_ version, without the bang(!). While it sometimes may
not be the best way to achieve a particular goal (bad performance), it's as safe as it
gets. In fact, if `dm-validations` are required and active, calling the non-bang version
of any of these methods, will make sure that all validations are being run too.

Sometimes though, you either don't need the extra safety you get from `dm-validations`,
or you don't want any callbacks to be invoked at all. In situations like this, you can use
the _bang(!)_ versions of the respective methods. You will probably find yourself using these
_unsafe_ methods when performing internal manipulation of resources as opposed to, say,
persisting attribute values entered by users (in which case you'd most likely use the _safe_
versions). If you call `#save!` instead of `#save`, _no callbacks_ and _no validations_ will
be run. DataMapper just assumes that you know what you do. This can also have severe impact
on the performance of some operations. If you're calling `#save!`, `#update!` or `#destroy!`
on a (large) `DataMapper::Collection`, this will result in much better performance than calling
the _safe_ non-bang counterparts. This is because DataMapper won't load the collection into
memory because it won't execute any resource level callbacks or validations.

While the above examples mostly used `#save` and `#save!` to explain the different behavior,
the same rules apply for `#create!`, `#save!`, `#update!` and `#destroy!`. The _safe_ non-bang
methods will _always execute all callbacks and validations_, and the _unsafe_ bang(!) methods
_never will_.

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

If DataMapper is told to `raise_on_save_failure` it will raise the following when
any `save` operation failed:

{% highlight ruby %}
DataMapper::SaveFailureError: Zoo#save returned false, Zoo was not saved
{% endhighlight %}

You can then go ahead and `rescue` from this error.

The example Zoo
---------------

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

It is important to note that `#save` will save the complete _loaded_ object graph when called.
This means that calling `#save` on a resource that has relationships of any kind (established
via `belongs_to` or `has`) will also save those related resources, _if_ they are _loaded_ at the
time `#save` is being called. Related resources are _loaded_ if they've been accessed either
for _read_ or for _write_ purposes, prior to `#save` being called.

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

You can also use `#update` to do mass updates on a model. In the previous examples
we've used `DataMapper::Resource#update` to update a single resource. We can also
use `DataMapper::Model#update` which is available as a class method on our models.
Calling it will update all instances of the model with the same values.

{% highlight ruby linenos %}
Zoo.update(:name => 'Funky Town Municipal Zoo')
{% endhighlight %}

This will set all Zoo instances' name property to 'Funky Town Municipal Zoo'. Internally
it does the equivalent of:

{% highlight ruby linenos %}
Zoo.all.update(:name => 'Funky Town Municipal Zoo')
{% endhighlight %}

This shows that actually, `#update` is also available on any `DataMapper::Collection`
and performs a mass update on that collection when being called. You typically retrieve
a `DataMapper::Collection` from either a call to `SomeModel.all` or a call to a
relationship accessor for any `1:n` or `m:n` relationship.

Destroy
-------

To destroy a record, you simply call it's `#destroy` method. It will return
`true` or `false` depending if the record is successfully deleted or not. Here
is an example of finding an existing record then destroying it.

{% highlight ruby linenos %}
zoo = Zoo.get(5)
zoo.destroy  # => true
{% endhighlight %}

You can also use `#destroy` to do mass deletes on a model. In the previous examples
we've used `DataMapper::Resource#destroy` to destroy a single resource. We can also
use `DataMapper::Model#destroy` which is available as a class method on our models.
Calling it will remove all instances of that model from the repository.

{% highlight ruby linenos %}
Zoo.destroy
{% endhighlight %}

This will delete all Zoo instances from the repository. Internally it does the equivalent of:

{% highlight ruby linenos %}
Zoo.all.destroy
{% endhighlight %}

This shows that actually, `#destroy` is also available on any `DataMapper::Collection`
and performs a mass delete on that collection when being called. You typically retrieve
a `DataMapper::Collection` from either a call to `SomeModel.all` or a call to a
relationship accessor for any `1:n` or `m:n` relationship.
