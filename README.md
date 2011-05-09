# Consistency Fail

## Description
consistency_fail is a tool to detect missing unique indexes in Rails projects.

With more than one application server, validates_uniqueness_of becomes a lie.
Two app servers -> two requests -> two near-simultaneous uniqueness checks ->
two processes that commit to the database independently, violating this faux
constraint. You'll need a database-level constraint for cases like these.

consistency_fail will find your missing unique indexes, so you can add them and
stop ignoring the C in ACID.

## Installation

    gem install consistency_fail

Currently only Rails 2.x is supported. Rails 3 support is coming soon.

## Usage

The simplest run mode is to generate a report of the problematic spots in your
application. From your Rails project directory, run:

    consistency_fail

from your terminal / shell. This will spit a report to standard output, which
you can view directly, redirect to a file as evidence to embarrass a teammate,
or simply beam in happiness at your application's perfect record for
`validates_uniqueness_of` usage.

## License

Released under the MIT License. See the LICENSE file for further details.
