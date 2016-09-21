# https://developers.google.com/analytics/devguides/collection/analyticsjs/sending-hits
jQuery ->
  $(document).on 'turbolinks:load', ->
    trackPageView()
    registerEventTracking()

@trackPageView = ->
  if window.ga?
    ga('set',  'location', location.href.split('#')[0])
    ga('set',  'userId',   document.current_user_id) if document.current_user_id?
    ga('send', 'pageview', { "title": document.title })

@registerEventTracking = ->
  # No JQuery, yay!
  document.querySelectorAll('a[ga-event-category]').forEach (item, i) ->
    item.addEventListener 'mousedown', (eventType) =>
      ga 'send', 'event',
        eventCategory: item.getAttribute("ga-event-category")
        eventAction: item.getAttribute("ga-event-action")
        eventLabel: item.getAttribute("ga-event-label")
        transport: 'beacon'

      return true
