---
layout:     default
body_id: news
title: DataMapper News and Notes
---

{{ page.title }}
================

<dl>

  {% for post in site.posts limit:20 %}

    <dt><a href="{{ post.url }}"> {{ post.title }}</a></dt>
    <dd>
      <p>{{ post.summary }}</p>
      <p class="meta">{{ post.date | date_to_long_string }} by {{ post.author }}</p>
    </dd>

  {% endfor %}

</dl>

<p>
  {{ paginator.previous_page }}
  {{ paginator.next_page }}
</p>
