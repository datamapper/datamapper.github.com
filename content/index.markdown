---
layout:       default
body_id:      home
title:        DataMapper
---

<p class="blurb" markdown="true">DataMapper is a [Object Relational Mapper](http://en.wikipedia.org/wiki/Object-relational_mapping) written in [Ruby](http://ruby-lang.org/).
The goal is to create an ORM which is fast, thread-safe and feature rich.</p>

<p class="blurb" markdown="true">To learn a little more about this project and
why you should be interested,<br> read the [Why Datamapper?](/why) page.</p>

<h2 class="latest-release">Recent News</h2>

<% latest_article = items_with_tag('important').first %>
<p class="latest-release"><%= latest_article[:title] %><br/>
  <%= latest_article[:summary] %><br/>
  <a href="<%= latest_article.identifier %>" class="read_more">Read more</a>
</p>

<div id="help" markdown="true">
Help
----

If you're having trouble, don't forget to check the documentation, which has
both references and step by step tutorials.

[Read documentation](/docs)
</div>

<div id="bugs" markdown="true">
Issues
------

If you're still having trouble, or you think you came across something you think
might be a bug, let us know.

[Log a ticket](http://datamapper.lighthouseapp.com/projects/20609-datamapper/overview)
</div>

News
----

<dl>
<% sorted_articles.each do |article| %>
  <dt><a href="<%= article.identifier %>"><%= article[:title] %></a></dt>
  <dd>
    <p><%= article[:summary] %></p>
    <p class="meta"><%= article[:published_at] %> by <%= article[:author] %></p>
  </dd>
<% end %>
</dl>
