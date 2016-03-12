$ ->
  $('textarea[dropped-files-url]').on 'drop', (event) ->
    event.preventDefault()

    textarea = $(this)
    url      = textarea.attr('dropped-files-url')
    file     = event.originalEvent.dataTransfer.files[0]

    addUploadPlaceholder(textarea, file)
    uploadFile url, file, (data, xhr)->
      replaceUploadPlaceholder(textarea, file, data)

@uploadFile = (url, file, callback)->
  console.log('file:uploading -> ', url, file)
  data  = new FormData
  data.append 'file', file
  $.ajax
    url: url
    type: 'POST'
    data: data
    cache: false
    dataType: 'json'
    headers:
      'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
      "Accept": "text/javascript"
    processData: false
    contentType: false
    success: (data, text, xhr) ->
      console.log('file:uploaded -> ', data, xhr)
      callback(data, xhr)

@addUploadPlaceholder = (el, file) ->
  insertTextAtCursor(el, uploadPlaceholder(file.name))

@insertTextAtCursor = (el, text)->
  originalText = el.val()
  newText      = originalText + "\n" + text
  el.val(newText)

@uploadPlaceholder = (name) ->
  "![Uploading... #{name}]()"

@replaceUploadPlaceholder = (el, file, data) ->
  picture     = data.picture
  placeholder = uploadPlaceholder(picture.name)
  replacement = if picture.type.match(/image|pdf|png|psd/)
    "![#{picture.name}](#{picture.url})"
  else
    "[#{picture.name}](#{picture.url})"
  el.val(el.val().replace(placeholder, replacement))
