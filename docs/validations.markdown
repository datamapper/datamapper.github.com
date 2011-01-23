---
layout:     default
title:      Validations
body_id:    docs
created_at: Fri Jun 13 17:41:32 +1030 2007
---

{{ page.title }}
================

DataMapper validations allow you to vet data prior to saving to a database. To
make validations available to your app you simply '`require "dm-validations"`'
in your application. With DataMapper there are two different ways you can
validate your classes' properties.

Manual Validation
-----------------

Much like a certain other Ruby ORM we can call validation methods directly by
passing them a property name (or multiple property names) to validate against.

{% highlight ruby linenos %}
  validates_length_of :name
  validates_length_of :name, :description
{% endhighlight %}

These are the currently available manual validations available. Please refer to
the [API docs](http://rubydoc.info/gems/dm-validations/1.0.2/frames) for more detailed
information.

* [validates_absence_of](http://rubydoc.info/gems/dm-validations/1.0.2/DataMapper/Validations/ValidatesAbsence)
* [validates_acceptance_of](http://rubydoc.info/gems/dm-validations/1.0.2/DataMapper/Validations/ValidatesAcceptance)
* [validates_with_block](http://rubydoc.info/gems/dm-validations/1.0.2/DataMapper/Validations/ValidatesWithBlock)
* [validates_confirmation_of](http://rubydoc.info/gems/dm-validations/1.0.2/DataMapper/Validations/ValidatesConfirmation)
* [validates_format_of](http://rubydoc.info/gems/dm-validations/1.0.2/DataMapper/Validations/ValidatesFormat)
* [validates_length_of](http://rubydoc.info/gems/dm-validations/1.0.2/DataMapper/Validations/ValidatesLength)
* [validates_with_method](http://rubydoc.info/gems/dm-validations/1.0.2/DataMapper/Validations/ValidatesWithMethod)
* [validates_numericality_of](http://rubydoc.info/gems/dm-validations/1.0.2/DataMapper/Validations/ValidatesNumericality)
* [validates_primitive_type_of](http://rubydoc.info/gems/dm-validations/1.0.2/DataMapper/Validations/ValidatesPrimitiveType)
* [validates_presence_of](http://rubydoc.info/gems/dm-validations/1.0.2/DataMapper/Validations/ValidatesPresence)
* [validates_uniqueness_of](http://rubydoc.info/gems/dm-validations/1.0.2/DataMapper/Validations/ValidatesUniqueness)
* [validates_within](http://rubydoc.info/gems/dm-validations/1.0.2/DataMapper/Validations/ValidatesWithin)

Auto-Validations
----------------

By adding triggers to your property definitions you can both define and validate
your classes properties all in one fell swoop.

Triggers that generate validator creation:

{% highlight ruby %}
  # implicitly creates a validates_present
  :required => true  # cannot be nil

  # implicitly creates a validates_length
  :length => 0..20  # must be between 0 and 20 characters in length
  :length => 1..20  # must be between 1 and 20 characters in length

  # implicitly creates a validates_format
  :format => :email_address  # predefined regex
  :format => :url            # predefined regex
  :format => /\w+_\w+/
  :format => lambda { |str| str }
  :format => proc { |str| str }
  :format => Proc.new { |str| str }
{% endhighlight %}


Here we see an example of a class with both a manual and auto-validation declared:

{% highlight ruby linenos %}
  require 'dm-validations'

  class Account
    include DataMapper::Resource

    property :name, String

    # good old fashioned manual validation
    validates_length_of :name, :max => 20

    property :content, Text, :length => 100..500
  end
{% endhighlight %}

Validating
----------

DataMapper validations, when included, alter the default save/create/update
process for a model.

You may manually validate a resource using the `valid?` method, which will
return true if the resource is valid, and false if it is invalid.

Working with Validation Errors
------------------------------

If your validators find errors in your model, they will populate the
[Validate::ValidationErrors][Validate_ValidationErrors] object that is available
through each of your models via calls to your model's `errors` method.

{% highlight ruby linenos %}
  my_account = Account.new(:name => 'Jose')
  if my_account.save
    # my_account is valid and has been saved
  else
    my_account.errors.each do |e|
      puts e
    end
  end
{% endhighlight %}

Error Messages
--------------

The error messages for validations provided by DataMapper are generally clear,
and explain exactly what has gone wrong. If they're not what you want though,
they can be changed. This is done via providing a `:message` in the options
hash, for example:

{% highlight ruby %}
  validates_uniqueness_of_ :title, :scope => :section_id,
    :message => "There's already a page of that title in this section"
{% endhighlight %}

This example also demonstrates the use of the `:scope` option to only check the
property's uniqueness within a narrow scope. This object won't be valid if
another object with the same @section_id@ already has that title.

Something similar can be done for auto-validations, too, via setting `:messages`
in the property options.

{% highlight ruby %}
  property :email, String, :required => true, :unique => true,
    :format   => :email_address,
    :messages => {
      :presence  => 'We need your email address.',
      :is_unique => 'We already have that email.',
      :format    => 'Doesn't look like an email address to me ...'
    }
{% endhighlight %}

To set an error message on an arbitrary field of the model, DataMapper provides
the `add` command.

{% highlight ruby linenos %}
  @resource.errors.add(:title, "Doesn't mention DataMapper")
{% endhighlight %}

This is probably of most use in custom validations, so ...

Custom Validations
------------------

DataMapper provides a number of validations for various common situations such
as checking for the length or presence of strings, or that a number falls in a
particular range. Often this is enough, especially when validations are combined
together to check a field for a number of properties. For the situations where
it isn't, DataMapper provides a couple of methods: `validates_with_block` and
`validates_with_method`. They're very similar in operation, with one accepting a
block as the argument and the other taking a symbol representing a method name.

The method or block performs the validation tests and then should return `true`
if the resource is valid or `false` if it is invalid. If the resource isn't
valid instead of just returning `false`, an array containing `false` and an
error message, such as `[ false, 'FAIL!' ]` can be returned. This will add the
message to the `errors` on the resource.

{% highlight ruby linenos %}
  class WikiPage
    include DataMapper::Resource

    # properties ...

    validates_with_method :check_citations

    # checks that we've included at least 5 citations for our wikipage.
    def check_citations
      # in a 'real' example, the number of citations might be a property set by
      # a before :valid? hook.
      num = count_citations(self.body)
      if num > 4
        return true
      else
        [ false, "You must have at least #{5 - num} more citations for this article" ]
      end
    end
  end
{% endhighlight %}

Instead of setting an error on the whole resource, you can set an error on an
individual property by passing this as the first argument to
`validates_with_block` or `validates_with_method`. To use the previous example,
replacing line 5 with:

{% highlight ruby %}
  validates_with_method :body, :method => :check_citations
{% endhighlight %}

This would result in the citations error message being added to the error
messages for the body, which might improve how it is presented to the user.

Conditional Validations
-----------------------

Validations don't always have to be run. For example, an issue tracking system
designed for git integration might require a commit identifier for the fix--but
only for a ticket which is being set to 'complete'. A new, open or invalid
ticket, of course, doesn't necessarily have one. To cope with this situation and
others like it, DataMapper offers conditional validation, using the `:if` and
`:unless` clauses on a validation.

`:if` and `:unless` take as their value a symbol representing a method name or a
Proc. The associated validation will run only if (or unless) the method or Proc
returns something which evaluates to `true`. The chosen method should take no
arguments, whilst the Proc will be called with a single argument, the resource
being validated.

{% highlight ruby linenos %}
  class Ticket
    include DataMapper::Resource

    property :id,          Serial
    property :title,       String, :required => true
    property :description, Text
    property :commit,      String
    property :status,      Enum[ :new, :open, :invalid, :complete ]

    validates_presence_of :commit, :if => lambda { |t| t.status == :complete }
  end
{% endhighlight %}

The autovalidation that requires the title to be present will always run, but
the validates_present on the commit hash will only run if the status is
`:complete`. Another example might be a change summary that is only required if
the resource is already there--'initial commit' is hardly an enlightening
message.

{% highlight ruby %}
  validates_length_of :change_summary, :min => 10, :unless => :new?
{% endhighlight %}

Sometimes a simple on and off switch is not enough, and so ...

Contextual Validations
----------------------

DataMapper Validations also provide a means of grouping your validations into
contexts. This enables you to run different sets of validations under different
contexts. All validations are performed in a context, even the auto-validations.
This context is the `:default` context. Unless you specify otherwise, any
validations added will be added to the `:default` context and the `valid?`
method checks all the validations in this context.

One example might be differing standards for saving a draft version of an
article, compared with the full and ready to publish article. A published
article has a title, a body of over 1000 characters, and a sidebar picture. A
draft article just needs a title and some kind of body. The length and the
sidebar picture we can supply later. There's also a `published` property, which
is used as part of queries to select articles for public display.

To set a context on a validation, we use the `:when` option. It might also be
desirable to set `:auto_validation => false` on the properties concerned,
especially if we're messing with default validations.

{% highlight ruby linenos %}
  class Article
    include DataMapper::Resource

    property :id,          Serial
    property :title,       String
    property :picture_url, String
    property :body,        Text
    property :published,   Boolean

    # validations
    validates_presence_of :title,       :when => [ :draft, :publish ]
    validates_presence_of :picture_url, :when => [ :publish ]
    validates_presence_of :body,        :when => [ :draft, :publish ]
    validates_length_of   :body,        :when => [ :publish ], :minimum => 1000
    validates_absence_of  :published,   :when => [ :draft ]
  end

  # and now some results
  @article = Article.new

  @article.valid?(:draft)
  # => false.  We have no title, for a start.

  @article.valid_for_publish?
  # => false.  We have no title, amongst many other issues.
  # valid_for_publish? is provided shorthand for valid?(:publish)

  # now set some properties
  @article.title = 'DataMapper is awesome because ...'
  @article.body  = 'Well, where to begin ...'

  @article.valid?(:draft)
  # => true.  We have a title, and a little body

  @article.valid?(:publish)
  # => false.  Our body isn't long enough yet.

  # save our article in the :draft context
  @article.save(:draft)
  # => true

  # set some more properties
  @article.picture_url = 'http://www.greatpictures.com/flower.jpg'
  @article.body        = an_essay_about_why_datamapper_rocks

  @article.valid?(:draft)
  # => true.  Nothing wrong still

  @article.valid?(:publish)
  # => true.  We have everything we need for a full article to be published!

  @article.published = true

  @article.save(:draft)
  # => false.  We set the published to true, so we can't save this as a draft.
  # As long as our drafting method always saves with the :draft context, we won't ever
  # accidentally save a half finished draft that the public will see.

  @article.save(:publish)
  # => true
  # we can save it just fine as a published article though.
{% endhighlight %}

That was a long example, but it shows how to set up validations in differing
contexts and also how to save in a particular context. *One thing to be careful
of when saving in a context is to make sure that any database level constraints,
such as a `NOT NULL` column definition in a database, are checked in that
context, or a data-store error may ensue.*

Setting Properties Before Validation
------------------------------------

It is sometimes necessary to set properties before a resource is saved or
validated. Perhaps a required property can have a default value set from other
properties or derived from the environment. To set these properties, a `before :valid?`
<a href="/docs/callbacks">hook</a> should be used.

{% highlight ruby linenos %}
  class Article
    include DataMapper::Resource

    property :id,        Serial
    property :title,     String, :required => true
    property :permalink, String, :required => true

    before :valid?, :set_permalink

    # our callback needs to accept the context used in the validation,
    # even if it ignores it, as #save calls #valid? with a context.
    def set_permalink(context = :default)
      self.permalink = title.gsub(/\s+/, '-')
    end
  end
{% endhighlight %}

Be careful not to `save` your resource in these kinds of methods, or your
application will spin off into infinite trying to save your object while saving
your object.
