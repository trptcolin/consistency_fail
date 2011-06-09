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


## Installation

    gem install consistency_fail

## Limitations

consistency\_fail depends on being able to find all your `ActiveRecord::Base`
subclasses with some `$LOAD_PATH` trickery. If any models are in a path either
not on your project's load path or in a path that doesn't include the word
"models", consistency\_fail won't be able to find or analyze them.

## Usage

The only run mode for now is to generate a report of the problematic spots in
your application. From your Rails project directory, run:

    consistency_fail

from your terminal / shell. This will spit a report to standard output, which
you can view directly, redirect to a file as evidence to embarrass a teammate,
or simply beam in happiness at your application's perfect record for
`validates_uniqueness_of` and `has_one` usage.

## Coming Soon

* Handling validates\_uniqueness\_of calls scoped to an association (not a column)
* Rails 3 support
* Super-fail mode that monkey-patches explosions into your naughty models

## License

Released under the MIT License. See the LICENSE file for further details.
