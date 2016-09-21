jQuery ->
  console.log('BSA -> Loading')
  bsa = document.createElement('script')
  bsa.type = 'text/javascript'
  bsa.async = true
  bsa.src = document.location.protocol + '//s3.buysellads.com/ac/bsa.js'
  (document.getElementsByTagName('head')[0] or document.getElementsByTagName('body')[0]).appendChild(bsa)

  $(document).on 'turbolinks:load', ->
    if window._bsap?
      console.log("BSA -> Reloading")
      _bsap.reload()
