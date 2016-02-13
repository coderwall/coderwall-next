jQuery ->
  $(document).on 'page:change', ->
    if window.ga?
      ga('set',  'location', location.href.split('#')[0])
      ga('send', 'pageview', { "title": document.title })
