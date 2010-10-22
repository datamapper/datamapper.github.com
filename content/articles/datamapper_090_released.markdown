---
layout:       articles
kind:         article
tags:         important
title:        DataMapper 0.9 is Released
created_at:   2008-05-27T03:07:24-05:00
published_at: 2008-05-27
summary:      And you thought that The Great Refactoring was for naught
author:       ssmoot, afrench
---

<%= @item[:title] %>
================

DataMapper 0.9 is ready for the world. It brings with it a massive overhaul of
the internals of DataMapper, a shift in terminology, a dramatic bump in speed,
improved code-base organization, and support for more than just database
data-stores.

To install it:

<pre><code class="language-bash">
sudo gem install addressable english rspec
sudo gem install data_objects do_mysql do_postgres do_sqlite3
sudo gem install dm-core
</code></pre>

This is NOT a backwards compatible release. Code written for DataMapper 0.3 will
not function with DataMapper 0.9.* due to syntactical changes and library
improvements.

REPEAT: This is NOT a backwards compatible release.

<table class="changeSummary" cellspacing="0" cellpadding="0">
  <thead>
    <th>&nbsp;</th>
    <th>DataMapper 0.3</th>
    <th>DataMapper 0.9</th>
  </thead>
  <tbody>
    <tr>
      <th>Creating a class</th>
      <td>
<pre><code class="language-ruby">
class Post < DataMapper::Base
end
</code></pre>
      </td>
      <td>
<pre><code class="language-ruby">
class Post
  include DataMapper::Resource
end</code></pre>
      </td>
    </tr>
    <tr>
      <th>Keys</th>
      <td>
<pre><code class="language-ruby">
# Key was not mandatory
# Automatically added +id+ if missing
#
# Natural Key
property :name, :string, :key => true
#
# Composite Key
property :id, :integer,  :key => true
property :slug, :string, :key => true
</code></pre>
      </td>
      <td>
<pre><code class="language-ruby">
# keys are now mandatory
property :id,   Serial
#
# Natural Key
property :slug, String,  :key => true
#
# Composite Key
property :id,   Integer, :key => true
property :slug, String,  :key => true
</code></pre>
      </td>
    </tr>
    <tr>
      <th>Properties</th>
      <td>
<pre><code class="language-ruby">
property :title,     :string
property :body,      :text
property :posted_on, :datetime
property :active,    :boolean
</code></pre>
      </td>
      <td>
<pre><code class="language-ruby">
property :title,     String
property :body,      Text
property :posted_on, DateTime
property :active,    Boolean
</code></pre>
      </td>
    </tr>
    <tr>
      <th>Associations</th>
      <td>
<pre><code class="language-ruby">
has_many :comments
belongs_to :blog
has_and_belongs_to_many :categories
has_one :author
</code></pre>
      </td>
      <td>
<pre><code class="language-ruby">
has n, :comments
belongs_to :blog
has n, :categories => Resource
has 1, :author
</code></pre>
      </td>
    </tr>
    <tr>
      <th>Finders</th>
      <td>
        <pre><code class="language-ruby">
Post.first :order => 'created_at DESC'
Post.all
  :conditions => [ 'active = ?', true ]

database.query 'SELECT 1'
database.execute 'UPDATE posts...'
        </code></pre>
      </td>
      <td>
        <pre><code class="language-ruby">
Post.first :order => [ :created_at.desc ]
Post.all
  :conditions => [ 'active = ?', true ]

repository(:default).adapter.query 'SELECT 1'
repository(:default).adapter.execute 'UPDATE posts...'
        </code></pre>
      </td>
    </tr>
    <tr>
      <th>Validations</th>
      <td>
        <pre><code class="language-ruby">
validates_presence_of     :title
validates_numericality_of :rating
validates_format_of       :email,   :with => :email_address
validates_length_of       :summary, :within => 1..100
validates_uniqueness_of   :slug
        </code></pre>
      </td>
      <td>
        <pre><code class="language-ruby">
validates_present   :title
validates_is_number :rating
validates_format    :email,   :as => :email_address
validates_length    :summary, :in => 1..100
validates_is_unique :slug
        </code></pre>
      </td>
    </tr>
    <tr>
      <th>Callbacks</th>
      <td>
<pre><code class="language-ruby">
before_save :categorize

before_create do |post|
  # do stuff with post
end

# return false to abort
</code></pre>
      </td>
      <td>
<pre><code class="language-ruby">
before :save, :categorize

before :create do
  # do stuff with self
end

# throw :halt to abort
</code></pre>
      </td>
    </tr>
  </tbody>
</table>
