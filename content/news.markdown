---
layout:     default
body_id: news
title: DataMapper News and Notes
---

<%= @item[:title] %>
================

<dl>

  <% sorted_articles.each do |article| %>

    <dt><a href="<%= article.identifier %>"><%= article[:title] %></a></dt>
    <dd>
      <p><%= article[:summary] %></p>
      <p class="meta"><%= article[:published_at] %> by <%= article[:author] %></p>
    </dd>

  <% end %>

</dl>
