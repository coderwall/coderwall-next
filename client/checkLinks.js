#!/usr/bin/env node
var roboto = require('roboto');

var crawler = new roboto.Crawler({
  startUrls: [
    'http://coderwall.dev:5000/'
  ],
  // We don't want it crawling outside links.
  constrainToRootDomains: true,
});

var deadLinks = [];
crawler.on('httpError', function(statusCode, href, referer) {
  if (statusCode === 404) {
    deadLinks.push({
      href: href,
      referer: referer
    });
  }
});

crawler.on('finish', function() {
  for (var i = 0; i < deadLinks.length; i ++) {
    var deadLink = deadLinks[i];
    console.log('Dead link: %s  found on page: %s', deadLink.href, deadLink.referer);
  }
});

crawler.crawl();
