# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require react
#= require react_ujs
#= require_tree .

$ ->
  $(document).bind "ajax:error", (event, jqXHR, ajaxSettings, thrownError) ->
    if jqXHR.status == 401 # thrownError is 'Unauthorized'
      window.location.replace('/signin')

  # resize text areas to adjust for space
  $('textarea').on 'input', ->
    textarea_to_resize = this
    textarea_new_hight = textarea_to_resize.scrollHeight
    textarea_to_resize.style.cssText = 'height:auto;'
    textarea_to_resize.style.cssText = 'height:' + textarea_new_hight + 'px'
    
