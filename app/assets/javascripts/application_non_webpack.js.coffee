# Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
# about supported directives.
#= require bsa
#= require analytics
#= require textarea_with_file_drop_support

document.addEventListener 'turbolinks:load', ->
  els = document.getElementsByTagName('textarea')
  for el in els
    el.addEventListener 'input', resizeTextAreaForNewInput

  el = document.querySelector('.js-popout')
  if el
    el.addEventListener('click', openPopout)

  unless document.current_user_id?
    setUserId()

@setUserId = ->
  userId = document.querySelector("meta[property='current_user:id']").content
  document.current_user_id = userId if userId?

@promptUserSignInOn401 = (xhr) ->
  if xhr.status == 401
    window.location.replace('/signin')
  return

@resizeTextAreaForNewInput = ->
  textarea_to_resize = this
  textarea_new_hight = textarea_to_resize.scrollHeight
  textarea_to_resize.style.cssText = 'height:auto;'
  textarea_to_resize.style.cssText = 'height:' + textarea_new_hight + 'px'

openPopout = ->
  w = window.open(@href, @target || "_blank", 'menubar=no,toolbar=no,location=no,directories=no,status=no,scrollbars=no,resizable=no,dependent,width=400,height=600,left=0,top=0')
  return !w
