jQuery ->
  if $('.bsarocks').length > 0
    console.log('Loading BSA')
    e = document.createElement('script')
    e.type = 'text/javascript'
    e.async = !0
    e.src = document.location.protocol + '//s3.buysellads.com/ac/bsa.js'
    (document.getElementsByTagName('head')[0] or document.getElementsByTagName('body')[0]).appendChild(e)


  $(document).on 'page:change', ->
    if window._bsap?
      console.log("Reloading BSA")
      _bsap.reload()
