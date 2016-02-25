$(document).on 'page:before-change', =>
  # reset cache
  document.current_user_likes = new Likes(document.current_user_id)

class @Likes
  data: null
  userId: null
  loading: null
  callbacksAfterDataLoad: []

  when_liked: (dom_id, callback)->
    if @userId?
      @whenLoaded =>
        if @data.indexOf(dom_id) > -1
          callback(@data)

  safelyRunCallbacksWithLoadedData: ->
    index = @callbacksAfterDataLoad.length - 1
    while index >= 0
      @callbacksAfterDataLoad[index](@data)
      @callbacksAfterDataLoad.splice index, 1
      index--

  whenLoaded: (callback)->
    if @loading == false
      callback()
    else if @loading == true
      @callbacksAfterDataLoad.push callback
    else
      @loading = true
      @callbacksAfterDataLoad.push callback
      @load()

  load: ->
    # custom xhr request to handle etag/http caching, jquery doesn;t
    url = '/users/' + @userId + '/likes.json'
    req = new XMLHttpRequest
    req.onreadystatechange = =>
      if req.readyState == XMLHttpRequest.DONE
        if req.status == 200 || req.status == 304
          console.log('likes -> loaded', req, req.getAllResponseHeaders())
          @data = JSON.parse(req.responseText)['likes']
          @safelyRunCallbacksWithLoadedData()
    req.open 'GET', url
    req.send()

    # $.ajax
    #   dataType: 'json',
    #   cache: true,
    #   ifModified: true,
    #   url: '/users/' + @userId + '/likes.json'
    #   success: (data, status, xhr) =>
    #     console.log('likes -> loaded', xhr)
    #     @data = data['likes']
    #     @safelyRunCallbacksWithLoadedData()

  constructor: (userId)->
    @userId = userId
    console.log('likes -> new', this)
