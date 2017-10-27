# Consistency Fail

## Description
consistency\_fail is a tool to detect missing unique indexes in Rails projects.

With more than one application server, `validates_uniqueness_of` becomes a lie.
Two app servers -> two requests -> two near-simultaneous uniqueness checks ->
two processes that commit to the database independently, violating this faux
constraint. You'll need a database-level constraint for cases like these.

consistency\_fail will find your missing unique indexes, so you can add them and
stop ignoring the C in ACID.

Similar problems arise with `has_one`, so consistency\_fail finds places where
database-level enforcement is lacking there as well.

For more detail, see [my blog post on the
subject](http://blog.8thlight.com/articles/2011/6/11/winning-at-consistency).


## Installation

You can install the gem directly:

    gem install consistency_fail

Or if you're using Bundler (which you probably are), add it to your Gemfile.

    gem 'consistency_fail'


## Limitations

The master branch should work for the following ActiveRecord versions:

- 5.x
- 4.x (*has a known issue around views*)
- 3.x
- 2.3 (on the `rails-2.3` branch)

The known issue with views in ActiveRecord 4.x is that in this version, the
connection adapter's `tables` method includes both tables and views. This means
that without additional monkeypatches to the various connection adapters, we
cannot reliably detect whether a given model is backed by a table or a view. I
wouldn't mind monkeypatching a bounded set of adapters, but I don't want to be
on the hook for arbitrary connection adapters that may require licenses to test
(e.g. SQL Server, Oracle).

consistency\_fail depends on being able to find all your `ActiveRecord::Base`
subclasses with some `$LOAD_PATH` trickery. If any models are in a path either
not on your project's load path or in a path that doesn't include the word
"models", consistency\_fail won't be able to find or analyze them. I'm open to
making the text "models" configurable if people want that. Please open an issue
or pull request if so!

## Usage

The normal run mode is to generate a report of the problematic spots in your
application. From your Rails project directory, run:

    consistency_fail

from your terminal / shell. This will spit a report to standard output, which
you can view directly, redirect to a file as evidence to embarrass a teammate,
or simply beam in happiness at your application's perfect record for
`validates_uniqueness_of` and `has_one` usage.

The somewhat more sinister and awesome run mode is to include an initializer
that does this:

    require 'consistency_fail/enforcer'
    ConsistencyFail::Enforcer.enforce!

This will make it so that you can't save or load any ActiveRecord models until
you go back and add your unique indexes. Of course, you'll need to make it so
Rails can find `consistency_fail/enforcer` by having `consistency_fail` in your
Gemfile, or by some other mechanism.

This mega-fail mode is nice to have if you have a large team and want to ensure
that new models or validations/associations follow the rules.

If you're using the `Enforcer`, depending on your project, you may need to
delay the initializer until later, so that model files can be loaded only once
gem dependencies have been satisfied. One possible way is to move the code above
to the end of `environment.rb` or to the more specific `config/environment/*` files.

## Using with Guard

There is a guard integration plugin available. See [guard-consistency_fail](https://github.com/ptyagi16/guard-consistency_fail).

## License

Released under the MIT License. See the LICENSE file for further details.
