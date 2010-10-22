---
layout:     default
title:      DM-Timestamps
created_at: 2008-09-06 14:11:54.160780 -05:00
---

<%= @item[:title] %>
================

DM-Timestamps provides automatic updates of `created_at` or `created_on` and
`updated_at` or `updated_on` properties for your resources. To use it, simply
`require 'dm-timestamps'` and assign one or all of these properties to your
Resource.

Here's some basic usage.

<pre><code class="language-ruby">
require 'rubygems'
require 'dm-core'
require 'dm-timestamps'

DataMapper.setup(:default, 'sqlite3::memory:')

class Post
  include DataMapper::Resource

  property :id,         Serial
  property :title,      String,   :length => 1..255
  property :created_at, DateTime
  property :created_on, Date
  property :updated_at, DateTime
  property :updated_on, Date
end
</code></pre>

If you're familiar with the 'magic' properties from ActiveRecord, this is very
similar. When your model is initially saved, DM-Timestamps will update that
object's `created_at` and/or `created_on` fields with the time of creation. When
the object is edited and then saved out to the data-store, DM-Timestamps will
update the `updated_at` and `updated_on` fields with the time of update.
