class Confirm {
  constructor(el) {
    this.message = el.getAttribute('data-confirm')
    if (this.message) {
      el.form.addEventListener('submit', this.confirm.bind(this))
    } else {
      console && console.warn('No value specified in `data-confirm`', el)
    }
  }

  confirm(e) {
    if (!window.confirm(this.message)) {
      e.preventDefault();
    }
  }
}

document.addEventListener('turbolinks:load', () => {
  Array.from(document.querySelectorAll('[data-confirm]')).forEach((el) => {
    new Confirm(el)
  })
})
