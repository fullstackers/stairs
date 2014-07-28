var http = require('http');
var srv = http.Server(function (req, res) {
  res.writeHead(200, 'Content-Type: application/json');
  res.write(JSON.stringify({some:{field:'data'}}));
  res.end();
});
srv.listen(3000);

var stairs = require('./..');
var extractData = stairs('extract data')
  .step('query api', function ($, next) {
    console.log('querying "%s"', $.url);
    http.get($.url, function (res) {
      $.body = '';
      res.on('data', function (chunk) { $.body = $.body + chunk; });
      res.on('end', next);
      res.on('error', next);
    });
  })
  .step('parse json', function ($) {
    console.log('the body \'%s\'', $.body);
    try { $.data = JSON.parse($.body); } 
    catch(e) { return next(e) }
    finally { this.skip('skip to') }
  })
  .step('skip to', function ($, next) {
    next(); 
  })
  .step('grab element', function ($, next) {
    console.log('the data %j', $.data);
    $.extracted = $.data.some.field;
    this.end();
  })
  .on('step', function (title, index, count) {
    console.log('on step "%s" which is %s/%s of process "%s"', title, index, count, this.title);
  })
  .on('error', function (err, $) { 
    console.error(err);
  }) 
  .on('done', function ($) {
    console.log('extracted %j', $.extracted);
  });

var urls = [
  'http://localhost:3000/',
  'http://localhost:3000/',
  'http://localhost:3000/',
  ];
urls.forEach(function (url) {
  extractData({url:url}, done);  
});

var i =0;
function done ($) {
  if (++i >= 3) {
    console.log('done.');
    process.exit(0);
  }
}
