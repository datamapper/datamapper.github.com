---
layout:  default
title:   Using Git
---

{{ page.title }}
================

The DataMapper project uses the Git <span class="caps">SCM</span>. Committers
need to use git to commit their code directly to the main repository.

This page contains information on getting Git installed, getting source code
with Git, and steps for working with Git.

Also, see these references: <a href="http://git-scm.com/course/svn.html">Git
&#8211; <span class="caps">SVN</span> Crash Course</a> and <a
href="http://www.kernel.org/pub/software/scm/git/docs/everyday.html">Everyday
<span class="caps">GIT</span> With 20 Commands Or So</a>

Getting Git for Your System
---------------------------

You can use an earlier version, but 1.5.x is definitely recommended.

* MacPorts has `git-core`
* Debian has `git-core`; (If you're using Etch, you can get a recent Git version from Backports <a href="http://backports.org/dokuwiki/doku.php?id=instructions">http://backports.org/dokuwiki/do&#8230;</a>)
* Get the source at <a href="http://git-scm.com/">http://git-scm.com/</a>.

Setup
-----

Configure Git with your proper name and email. This will display when you submit
changes to the DataMapper repository.

{% highlight bash %}
git config  --global user.name "My Name"
git config  --global user.email "my@email"
{% endhighlight %}

If you prefer to use different credentials for different projects, you can also
configure the above for a single repository only. See the git documentation.

Formatting Git Commit Messages
------------------------------

In general, use an editor to create your commit messages rather than passing
them on the command line. The format should be:

* A hard wrap at 72 characters
* A single, short, summary of the commit
* Followed by a single blank line
* Followed by supporting details

The supporting details could be a bulleted enumeration or an explanatory
paragraph. The single summary line helps folks reviewing commits. An example
commit:

{% highlight bash lineos %}
Fixes for Module#make_my_day return values.

* Return nil when passed ':('
* Return true when passed ':)'
* Updated specs for #make_my_day for nil argument case
* Updated CI excludes.
{% endhighlight %}

Getting the Code
----------------

DataMapper is hosted at <a href="http://github.com/datamapper/">GitHub</a>.
Getting the code is easy once you have git installed but is slightly different
depending on your access. In both cases that exact command will put the
repository in a local directory called dm. You can give it a different name just
by appending it to the command.

### New Users and Developers

{% highlight bash lineos %}
git clone git://github.com/datamapper/dm-core.git
{% endhighlight %}

### Committers with Commit Bit

{% highlight bash lineos %}
git clone git@github.com/datamapper/dm-core.git
{% endhighlight %}

Git Workflow
------------

Working with Git is significantly different than working with <span
class="caps">SVN</span>. In particular, although similar, git pull is not svn
update, git push is not svn commit, and git add is not svn add. If you are a
<span class="caps">SVN</span> user, be sure to read the man pages for the
different git commands.</p>

The following workflow is recommended by Rein and is the guideline for
contributing code to DataMapper.

<ol>
  <li>
    <p>Create a local working copy of the source code (we did this earlier.)</p>
    {% highlight bash %}
    # See above for the exact invocation
    {% endhighlight %}
  </li>

  <li>
    <p>Change to the newly created directory that contains the local working copy. (Substitute the directory if you created it with a different name, obviously.)</p>
    {% highlight bash %}
   cd dm
   {% endhighlight %}
  </li>

  <li>
    <p>Create a branch for your work. It is important that you do your work in a local branch, rather than master.</p>
    {% highlight bash %}
    git checkout -b new_feature
    {% endhighlight %}
  </li>

  <li>
    <p>Edit the code and test your changes. Then commit to your local working copy.</p>
    {% highlight bash %}
    git add .
    git commit
    {% endhighlight %}
    </li>

  <li>
    <p>When you are ready to send your local changes back to the DataMapper repository, you first need to ensure that your local copy is up-to-date. First, ensure you have committed your local changes. Then switch from your topic branch to the master branch.</p>
    {% highlight bash %}
    git checkout master
    {% endhighlight %}
  </li>

  <li>
    <p>Update your local copy with changes from the DataMapper repository</p>
    {% highlight bash %}
    git pull origin master --rebase
    {% endhighlight %}
  </li>

  <li>
    <p>Switch back to your topic branch and integrate any new changes. The git rebase command will save your changes away, update the topic branch, and then reapply them.</p>
    {% highlight bash %}
    git checkout new_feature
    git rebase master
    {% endhighlight %}
    <p>Warning! If you have shared the topic branch publicly, you must use</p>

    {% highlight bash %}
    git merge master
    {% endhighlight %}
    <p>Rebase causes the commit layout to change and will confuse anyone
    you&#8217;ve shared this branch with.</p> </li>

  <li>
    <p>If there are conflicts applying your changes during the git rebase command, fix them and use the following to finish applying them</p>
    {% highlight bash %}
    git rebase --continue
    {% endhighlight %}
  </li>

  <li>
    <p>Now, switch back to the master branch and merge your changes from the topic branch</p>
    {% highlight bash %}
    git checkout master
    git merge new_feature
    {% endhighlight %}
  </li>

  <li>
    <p>You might want to check that your commits ended up as you intended. To do so, you can have a look at the log</p>
    {% highlight bash %}
    git log
    {% endhighlight %}
  </li>

  <li>
    <p>Get your changes in the main repository. If you have commit rights, you can just use the git push command. Otherwise, see the section below for information on creating a set of patches to send.</p>
    {% highlight bash %}
    git push origin master
    {% endhighlight %}
  </li>

  <li>
    <p>At this point, you can delete the branch if you like.</p>
    {% highlight bash %}
    git branch -d new_feature
    {% endhighlight %}
  </li>
</ol>

Patches: git-format-patch
-------------------------

If you are a new committer (or want to create a patch instead of directly
pushing the code for some other reason) you should create a patch file for your
commits. The patch file should be then attached to a ticket on Lighthouse. You
can also send the patch to the mailing list but please use the ticket tracker if
at all possible. Either way, the patch file(s) should be created using Git.

First, make your changes as detailed below and then use the git format-patch
command to create the patch files. Usually using the command is as simple as
specifying the commits you want to create patches for, and that is done in one
of two ways: by giving a range of commits or a starting point.

For our purposes, the simplest way to create a patch is to begin at the end of
step 8 above (after you have rebased your branch) and then, instead of
merging:

{% highlight bash %}
git format-patch master..
{% endhighlight %}

This will create a separate patch file for each commit in your working branch
that is not in master, named `[number]-[first line of commit message].patch`. You
can then attach these to a ticket (or e-mail them).

You can also inspect your changes using `git log master..` or `git diff master..`
to ensure that the patches will be generated correctly if you are uncertain.
