[![Build Status](https://travis-ci.org/turbonetix/stairs.svg?branch=master)](https://travis-ci.org/turbonetix/stairs)
[![NPM version](https://badge.fury.io/js/stairs.svg)](http://badge.fury.io/js/stairs)
[![David DM](https://david-dm.org/turbonetix/stairs.png)](https://david-dm.org/turbonetix/stairs.png)

Organize your application's steps with `stairs`.

Here we are building an *extraction* process to extract data from some API.

```javascript
var stairs = require('stairs');

var extractData = stairs('extract data')
  .step('query api', function ($, next) {
    http.get($.url, function (res) {
      $.body = '';
      res.on('data', function (chunk) { $.body = $.body + chunk; });
      res.on('end', next);
      res.on('error', next);
    });
  })
  .step('parse json', function ($) {
    try { $.data = JSON.parse($.body); } 
    catch(e) { return next(e) };
    finally { this.skip('skip to') }
  })
  .step('skip to', function ($, next) {
    this.next();
  })
  .step('grab element', function ($, next) {
    $.extracted = $.data.some.field;
    this.end();
  })
  .on('step', function (title, index, count) {
    console.log('on step "%s" which is %s/%s of process "%s"', title, index, count, this.title);
  });
  .on('error', function (err, $) { 
    console.error(err);
  }) 
  .on('done', function (err, $) {
    console.log('extracted %j', $.extracted);
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

# API

## Stairs

```javascript
var stairs = require('stairs');
```

### Stairs#()

Creates a new instance.

```javascript
var s = stairs();
```

### Stairs#(title:String)

Creats a new instance with a `title`.

```javascript
var s = stairs('extraction process');
```

### Stairs#()

Executes the steps in the order in which they were added.

```javascript
s();
```

### Stairs#(cb:Function)

Executes the steps in the order in which they were added, and when done
invokes the callback `cb`.

```javascript
s(function ($) {
  console.log($);
});
```

### Stairs#(scope:Object, cb:Function)

Executes the steps in the order in which they were added given a `scope` and when done
invokes the callback `cb`.

```javascript
s({}, function ($) {
  console.log($);
});
```

### Stairs#run(scope:Object)

Executes the steps in the order in which they were added given a `scope`.

```javascript
s.run({});
```

### Stairs#run(cb:Function)

Executes the steps in the order in which they were added, and when done
invokes the callback `cb`.

```javascript
s.run(function ($) {
  console.log($);
});
```

### Stairs#run(scope:Object, cb:Function)

Executes the steps in the order in which they were added given a `scope` and when done
invokes the callback `cb`.

```javascript
s.run({}, function ($) {
  console.log($);
});
```

### Stairs#step(title:String, fn:Function)

Adds a step.  The step function `fn` when invoked will get all
the parameters in the scope.  For most application you may only use
one.  The last argument will be the `next` function that will invoke the
next step.  You may pass an `Error` object when calling `next` in order to
stop the flow of execution and handle the error.

```javascript
s.step('query api', function ($, next) {
  http.get($.url, function (res) {
    $.body = '';
    res.on('data', function (chunk) { $.body = $.body + chunk; });
    res.on('end', next);
    res.on('error', next);
  });
});
```

### Stairs.Context#skip(title:String)

You can skip to a particular step given the `title` of that step by calling `this.skip('skip to')`.

```javascript
s.step('parse json', function ($, next) {
  try { $.data = JSON.parse($.body); } 
  catch(e) { return next(e) };
  finally { this.skip('skip to') }
});
```

### Stairs.Context#next()

You can invoke `next` from the callback parameter `next` or `this.next()`.

```javascript
s.step('skip to', function ($, next) {
  this.next();
});
```

### Stairs.Context#end()

You can end the process by calling `this.end()` in your handler.

```javascript
s.step('grab element', function ($, next) {
  console.log('the data %j', $.data);
  $.extracted = $.data.some.field;
  this.end();
});
```

### Events

#### step

The `step` event is triggered for each step when being executed.

```javascript
s.on('step', function (title, i, count) {
  console.log('we are processing step "%s" which is step %s of %s', title, i, count);
});
```

#### done

The `done` event is triggered when the process is complete.

```javascript
s.on('done', function ($) {
  console.log('done.');
});
```

#### error

The `error` event is triggered whenever we receive an error.

```javascript
s.on('error', function (err, $) {
  console.error(err);
});
```

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
