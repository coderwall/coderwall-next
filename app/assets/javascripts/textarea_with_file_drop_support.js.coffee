document.addEventListener 'turbolinks:load', ->
  textarea = document.querySelector('textarea[dropped-files-url]')
  if textarea
    textarea.addEventListener 'drop', (e) ->
      e.preventDefault()
      url   = textarea.getAttribute('dropped-files-url')
      files = e.target.files || e.dataTransfer.files
      file  = files[0]

      addUploadPlaceholder(textarea, file)
      uploadFile url, file, (data)->
        replaceUploadPlaceholder(textarea, file, data)

@uploadFile = (url, file, callback)->
  data  = new FormData
  data.append 'file', file

  request = new XMLHttpRequest()
  request.open('POST', url, true)
  request.setRequestHeader('X-CSRF-Token', document.getElementsByName('csrf-token')[0].content)
  request.setRequestHeader('Accept', 'text/javascript')
  request.send(data)
  request.onload = ->
    if (request.status >= 200 && request.status < 400)
      data = JSON.parse(request.responseText)
      callback(data)

@addUploadPlaceholder = (el, file) ->
  insertTextAtCursor(el, uploadPlaceholder(file.name))

@insertTextAtCursor = (el, text)->
  originalText = el.value
  newText      = originalText + "\n" + text
  el.value     = newText

@uploadPlaceholder = (name) ->
  "![Uploading... #{name}]()"

@replaceUploadPlaceholder = (el, file, data) ->
  picture     = data.picture
  placeholder = uploadPlaceholder(file.name)
  replacement = if picture.type.match(/image|pdf|png|psd/)
    "![#{file.name}](#{picture.url})"
  else
    "[#{file.name}](#{picture.url})"
  el.value = el.value.replace(placeholder, replacement)
