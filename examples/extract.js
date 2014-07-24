var http = require('http');
var srv = http.Server(function (req, res) {
  res.writeHead(200, 'Content-Type: application/json');
  res.write(JSON.stringify({some:{field:'data'}}));
  res.end();
});
srv.listen(3000);

var stairs = require('./..');
var extractData = stairs('extract data')
  .step('query api', function (scope, next) {
    console.log('querying "%s"', scope.url);
    http.get(scope.url, function (res) {
      scope.body = '';
      res.on('data', function (chunk) { scope.body = scope.body + chunk; });
      res.on('end', next);
      res.on('error', next);
    });
  })
  .step('parse json', function (scope, next) {
    console.log('the body \'%s\'', scope.body);
    try { scope.data = JSON.parse(scope.body); } 
    catch(e) { return next(e) }
    finally { next() }
  })
  .step('grab element', function (scope, next) {
    console.log('the data %j', scope.data);
    scope.extracted = scope.data.some.field;
    next()
  })
  .on('step', function (title, index, count) {
    console.log('on step "%s" which is %s/%s of process "%s"', title, index, count, this.title);
  })
  .on('error', function (err, scope) { 
    console.error(err);
  }) 
  .on('done', function (scope) {
    console.log('extracted %j', scope.extracted);
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
function done (scope) {
  if (++i >= 3) {
    console.log('done.');
    process.exit(0);
  }
}
