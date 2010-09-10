---
layout: default
title: Working with Legacy Schema
body_id: docs
created_at: Fri Sep 10 16:37:37 GMT 2010
---

{{ page.title }}
================

DataMapper has quite a few features and plugins which are useful for working
with legacy schemas. We're going to introduce the feature available in the core
first, before moving on to plugins. Note that whilst the title is "{{page.title }}",
really this applies to any situation where there is no control over over the
'table' in the data-store. These features could just as easily be used to
modify the fields returned by a RESTful webservice adapter, for example.

Small Tweaks
------------

If the number of modifications are small&mdash;just one table or a few
properties&mdash;it is probably easiest to modify the properties and table names
directly. This can be accomplished using the `:field` option for properties,
`:child_key` (or `:target`) for relationships, and manipulation of
`storage_names[]` for models.

{% highlight ruby linenos %}
class Post
  include DataMapper::Resource

  # set the storage name for the :legacy repository
  storage_names[:legacy] = 'tblPost'

  property :id, Serial, :field => :pid # use the 'pid' field in the data-store
                                        # for the id property.

  belongs_to :user, :child_key => [ :uid ] # use a property called 'uid' as the
                                           # child key the foreign key

end
{% endhighlights %}

Changing Behaviour
------------------

With one or two models, it is quite possible to tweak properties and models
using `:field` and `storage_names`. When there is a whole repository to rename,
naming conventions are an alternative. These apply to all the tables in the
repository. Naming conventions should be applied before the model is used as
the table name gets frozen when it is first used. DataMapper comes with a
number of naming conventions and custom ones can be defined:

{% highlight ruby linenos %}

# the DataMapper model
class Example::PostModel
end

# this is the default
DataMapper.repository(:legacy).adapter.resource_naming_convention = DataMapper::NamingConventions::Resource::UnderscoredAndPluralized
Example::PostModel.storage_names[:legacy]
#=> example_post_models

# underscored
DataMapper.repository(:legacy).adapter.resource_naming_convention = DataMapper::NamingConventions::Resource::Underscored
Example::PostModel.storage_names[:legacy]
#=> example/post_models

# without the module name
DataMapper.repository(:legacy).adapter.resource_naming_convention = DataMapper::NamingConventions::Resource::UnderscoredAndPluralizedWithoutModule
Example::PostModel.storage_names[:legacy]
#=> post_models

# custom conventions can be defined using procs, or any module which responds to #call
# They are passed the name of the model, as a string.
module ResourceNamingConvention
  def self.call(model_name)
    'tbl' + DataMapper::Inflector.classify(model_name)
  end
end

DataMapper.repository(:legacy).adapter.resource_naming_convention = ResourceNamingConvention
Example::PostModel.storage_names[:legacy]
#=> 'tblExample::PostModel'

{% endhighlight %}

For field names, use the `field_naming_convention` menthod. Field naming
conventions work in a similar manner, except the `#call` function is passed the
property name.
