#!/usr/bin/env node
/* eslint-disable */
const roboto = require('roboto')

const crawler = new roboto.Crawler({
  startUrls: [
    'http://coderwall.dev:5000/',
  ],
  // We don't want it crawling outside links.
  constrainToRootDomains: true,
})

const deadLinks = []
crawler.on('httpError', (statusCode, href, referer) => {
  if (statusCode === 404) {
    console.log('Dead link: %s  found on page: %s', href, referer)
    deadLinks.push({
      href,
      referer,
    })
  }
})

crawler.on('finish', () => {
  for (let i = 0; i < deadLinks.length; i++) {
    const deadLink = deadLinks[i]
    console.log('Dead link: %s  found on page: %s', deadLink.href, deadLink.referer)
  }
})

crawler.crawl()
