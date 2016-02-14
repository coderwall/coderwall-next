# https://developers.google.com/analytics/devguides/collection/analyticsjs/sending-hits
jQuery ->
  $(document).on 'page:change', ->
    if window.ga?
      ga('set',  'location', location.href.split('#')[0])
      ga('send', 'pageview', { "title": document.title })
