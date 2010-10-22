---
layout:       spotlight
kind:         article
title:        Spotlight on... Laziness
created_at:   2008-04-03T23:08:12-05:00
published_at: 2008-04-03
summary:      The Fastest Code Is No Code
author:       afrench
---

<%= @item[:title] %>
================

Laziness. It means "an unwillingness to work or use energy" and typically
indicates that the dishes don't get washed after lunch, the bath tub doesn't get
cleaned, and the trash sits around an extra few days and stinks up the place.

But that very same definition in software takes on a whole new meaning: To avoid
doing work you don't have to do for as long as you can avoid it; sometimes never
doing it at all. It's a good thing. It means that expensive and slow tasks can
be put off until the very last cycle possible and thus only incur their cost
when it really is worth it. Maybe you never execute the code at all.

You could put off running a specific subroutine because it's slow, or because it
locks a file that might be needed elsewhere, or because instantiating the
resulting object eats up RAM. Either way, deferring execution of a block of code
until the very last possible moment can be the difference between a snappy
application that rarely slows down and a slow application that rarely speeds up.

But laziness isn't without its hidden costs. If you put off everything to the
very last moment, you forfeit the opportunity to do more than one thing at a
time, and likely create more work for yourself, rather than less.

So where's the balance?

Ultimately, it depends on your application. The tools you use should offer you
the flexibility you need to design your application optimally. Every system,
after all, is unique and breaks the mold of systems before it.

This brings us to DataMapper.

Lazy-loading attributes
-----------------------

You likely already know that DataMapper supports lazy properties.

<pre><code class="language-ruby">
class Post
  include DataMapper::Resource

  property :id,    Serial                  # auto_incrementing primary key
  property :title, String, :lazy => true   # intentionally lazy
  property :body,  Text                    # lazy by default
end
</code></pre>

In this case, we're intentionally marking this Post's `:title` property as lazy,
as well as letting the `:body` be lazy by default. If we go and inspect our
query log for the retrieval of a post with the ID of 1, we see

<pre><code class="language-sql">
SELECT `id` FROM `posts` WHERE `id` = 1
</code></pre>

DataMapper didn't request the two lazy columns. But when we call `.title` off of
our post, we suddenly see

<pre><code class="language-sql">
SELECT `title` FROM `posts` WHERE `id` = 1
</code></pre>

This is the very definition of a lazy-loaded property; The lazy column didn't
get requested from our data store until we actually needed it, and no sooner.

But this is just for one individual instance of a post. How does this behave
when we have a collection of posts and iteratively call the `.title` method?

<pre><code class="language-sql">
SELECT `title` FROM `posts` WHERE `id` IN (1, 2, 3, 4, 5)
</code></pre>

DataMapper loaded up the title for all of the posts in our collection in one
query. It didn't issue the lazy-load retrieval from above over and over for each
individual post, nor did it chicken out and issue the lazy-load retrieval for
ALL of the posts in the data store.

When you retrieve a set of results using DataMapper's `.all`, each instance it
returns knows about the others in the result set, which makes it brutally simple
to issue just one lazy-load retrieval of `:title`, and thus solving the n+1
query problem without having to do anything special in the initial retrieval.

Contextual Lazy-loading
-----------------------

With a recent commit by [Guy van den Berg](http://web.archive.org/web/20080706235220/http://www.guyvdb.info/ruby/lazy-loading-properties-in-datamapper/),
DataMapper just got a whole lot more flexible.

Most applications have only a few main views of a resource: a brief summary view
used in listing results, a complete representation that might appear on a show
page and a comprehensive view for when someone is editing something and needs
access to metadata. Wouldn't it be nice to lump all of the lazy-load retrieval
queries into one query which loads up multiple lazy properties, rather than
query after query for each lazy property as you call them?

DataMapper now does this!

<pre><code class="language-ruby">
class Post
  include DataMapper::Resource

  property :id,    Serial
  property :title, String, :lazy => [ :summary, :brief ]
  property :body,  Text,   :lazy => [ :summary ]
end
</code></pre>

So now, when you load an attribute with the `:summary` context, DataMapper will
load up all of the other lazy-loaded properties marked `:summary` in one query
to the data store.

In your query log, you'll see:

<pre><code class="language-sql">
-- initial load
SELECT `id` FROM `posts`

-- lazy-loading of multiple properties in a given context in one query
SELECT `id`, `title`, `body` FROM `posts`
</code></pre>

If you use this wisely, it would mean that DataMapper will never load more than
it needs nor will it ever fire off more than the absolutely necessary amount of
queries to get the job done.

It's lazy ;-)

Strategic Eager Loading
-----------------------

Well, not for everything.

Returning for a little bit to our "loaded set" discussion from above, every item
you pull out of the data store is aware of any other item that got pulled along
with it. This is a very powerful feature which lets DataMapper defeat n+1 query
problems when dealing with associations as well as lazy-loading of properties.

For example, this is a severe "no no" in ActiveRecord:

<pre><code class="language-ruby">
  Zoo.find(:all).each do |zoo|
    zoo.animals
  end
</code></pre>

This is a very bad idea because the ORM must query the "animals" table over and
over again to load the association for each iteration. It's far better to use
`Zoo.find(:all, :include => [ :animals ]).each {}` because a JOIN occurs and
everything is retrieved in 1 query.

But the same issue doesn't exist in DataMapper. Each instance is aware of the
other instances it was retrieved with. The same iterator example from above only
fires off 2 queries as you're iterating and calling the association inside the
`each`. If you forget to `:include => [ :association ]` in the initial query,
DataMapper only ever fires off one more query to get what it needs.

[Yehuda Katz](http://yehudakatz.com/) has aptly named this 'Strategic Eager Loading'.

Getting Around to It
--------------------

A conclusion for our talk about laziness will be written whenever I get around
to it.

For now, just remember that DataMapper embraces lazy-loading, yet isn't overly
zealous when the lazy properties are finally retrieved. It also fills
associations strategically, and assumes you're going to iterate over the set of
results. You don't have to catch yourself when you write an iterator because
DataMapper loads associations for all of your items in the set, rather than on a
one-by-one basis.

And, most importantly, you can avoid doing work you don't have to do for as long
as you can avoid it.
