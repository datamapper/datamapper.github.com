---
layout:       default
body_id:      home
title:        DataMapper
---

<p class="blurb" markdown="true">DataMapper is a [Object Relational Mapper](http://en.wikipedia.org/wiki/Object-relational_mapping) written in [Ruby](http://www.ruby-lang.org/en/).
The goal is to create an ORM which is fast, thread-safe and feature rich.</p>

<p class="blurb" markdown="true">To learn a little more about this project and
why you should be interested,<br> read the [Why Datamapper?](/why) page.</p>

<h2 class="latest-release">Recent News</h2>

{% for post in site.tags.important limit:1 %}
<p class="latest-release">{{ post.title }}<br/>
  {{ post.summary }}<br/>
  <a href="{{ post.url }}" class="read_more">Read more</a>
</p>
{% endfor %}

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
{% for post in site.posts limit:20 %}

  <dt><a href="{{ post.url }}">{{ post.title }}</a></dt>
  <dd>
    <p>{{ post.summary }}</p>
    <p class="meta">{{ post.date | date_to_long_string }} by {{ post.author }}</p>
  </dd>

{% endfor %}
</dl> 

{{ paginator.previous_page }}
{{ paginator.next_page }}
