/* global Image, Promise */
export default function loadImage(url, timeout = 5000) {
  return new Promise((resolve, reject) => {
    let timedOut = false
    let timer
    const img = new Image()
    img.onerror = img.onabort = () => {
      if (!timedOut) {
        clearTimeout(timer)
        reject()
      }
    }
    img.onload = () => {
      if (!timedOut) {
        clearTimeout(timer)
        resolve()
      }
    }
    img.src = url
    timer = setTimeout(() => {
      timedOut = true
      reject()
    }, timeout)
  })
}
