[![Build Status](https://travis-ci.org/turbonetix/stairs.svg?branch=master)](https://travis-ci.org/turbonetix/stairs)
[![NPM version](https://badge.fury.io/js/stairs.svg)](http://badge.fury.io/js/stairs)
[![David DM](https://david-dm.org/turbonetix/stairs.png)](https://david-dm.org/turbonetix/stairs.png)

Organize your application's steps with `stairs`.

Here we are building an *extraction* process to extract data from some API.

```javascript
var stairs = require('stairs');

var extractData = stairs('extract data')
  .step('query api', function (scope, next) {
    http.get(scope.url, function (res) {
      scope.body = '';
      res.on('data', function (chunk) { scope.body = scope.body + chunk; });
      res.on('end', next);
      res.on('error', next);
    });
  })
  .step('parse json', function (scope, next) {
    try { scope.data = JSON.parse(scope.body); } 
    catch(e) { return next(e) };
    finally { next() }
  })
  .step('grab element', function (scope, next) {
    scope.extracted = scope.data.some.field;
    next()
  })
  .on('error', function (err, scope) { 
    console.error(err);
  }) 
  .on('done', function (err, scope) {
    console.log('extracted %j', scope.extracted);
  });
```

Next we apply our process to a list of urls.

```javascript
var urls = [
  'http://some.api?id=1'
  'http://some.api?id=2'
  'http://some.api?id=2'
].forEach(function (url) {
  extractData({url: url});
});
```

# Features

* Lean
* Simple
* Fast
* Easy

# Installation and Environment Setup

Install node.js (See download and install instructions here: http://nodejs.org/).

Clone this repository

    > git clone git@github.com:turbonetix/stairs.git

cd into the directory and install the dependencies

    > cd stairs
    > npm install && npm shrinkwrap --dev

# Running Tests

Install coffee-script

    > npm install coffee-script -g

Tests are run using grunt.  You must first globally install the grunt-cli with npm.

    > sudo npm install -g grunt-cli

## Unit Tests

To run the tests, just run grunt

    > grunt spec

## TODO
