wallboard [![Build Status](https://travis-ci.org/4lejandrito/wallboard.svg?branch=master)](https://travis-ci.org/4lejandrito/wallboard)
=========

Wallboard for software development teams

Building
--------

You will need the following pre-requisites on your system before you can run:

* Ruby 2.0.0 - https://www.ruby-lang.org
* Bundler >= 1.2.0 - http://bundler.io/

Once you have checked the code out, run the following command:
```
bundler install
```

This will install all of the required gems needed for the wallboard.

Running Tests
-------------

The tests are written using [RSpec](http://rspec.info).

Simply run the commnand ```rspec``` on the project's root folder.

Running
-------

Wallboard is a [Sinatra](http://www.sinatrarb.com/) app, so it can be run through [Rack](http://rack.github.io/):
```
rackup
```
