import React, { PropTypes as T } from 'react'

const requiredFields = [
  'company_name',
  'contact_email',
  'jobs_url',
]

export default class NewJobSubscription extends React.Component {
  static propTypes = {
    cost: React.PropTypes.number.isRequired,
    stripePublishable: React.PropTypes.string.isRequired,
  }
  
  constructor(props) {
    super(props)
    this.state = { brokenFields: {} }
  }

  render() {
    const csrfToken = document.getElementsByName('csrf-token')[0].content
    const saving = this.state.saving
    const valid = !Object.keys(this.state.brokenFields).length
    const submittable = valid && !saving

    return (
        <form ref="form" action="/jobs/subscriptions" acceptCharset="UTF-8" method="post"
          onSubmit={e => this.handleSubmit(e)}
          onBlur={e => this.handleBlur(e)}>
          <input name="utf8" type="hidden" defaultValue="✓" />
          <input type="hidden" name="authenticity_token" defaultValue={csrfToken} />
          <input type="hidden" name="stripeToken" value={this.state.stripeToken} />

          {this.textField('company_name', 'Company Name', 'Acme Inc.')}
          {this.textField('contact_email', 'Contact Email', 'coyote@acme.inc')}
          {this.textField('jobs_url', 'Career Website or Job Listing Page URL', 'eg. http://acme.com/jobs')}

          <span className="bold gray">That is all you have to do :D</span>

          <div className="center">
            <button
              className={`btn rounded mt3 white px4 py2 ${submittable ? 'bg-green' : 'bg-gray'}`}
              type="submit"
              disabled={!submittable}>
              Subscribe ($499 Monthly)
            </button>
          </div>

        </form>
    )
  }

  textField(name, label, placeholder) {
    return (
      <div>
        <label htmlFor={name}>{label}</label>
        <input
          id={name}
          value={this.state[name]}
          onChange={e => this.handleChange(name, e)}
          type="text"
          className={this.fieldClasses(name)}
          name={`job_subscription[${name}]`}
          placeholder={placeholder} />
      </div>
    )
  }

  fieldClasses(field) {
    return `field block col-12 mb3 ${this.state.brokenFields[field] && 'is-error'}`
  }

  handleSubmit(e) {
    e.preventDefault()
    if (!this.validateFields()) { return }

    this.setState({ saving: true })
    const onStripeTokenSet = token => {
      this.setState({ saving: true, stripeToken: token.id },
      () => this.refs.form.submit())
    }

    const onClosed = () => {
      if (!this.state.stripeToken) {
        this.setState({ saving: false })
      }
    }

    this.checkout = this.checkout || StripeCheckout.configure({
      closed: onClosed,
      image: 'https://s3.amazonaws.com/stripe-uploads/A6CJ1PO8BNz85yiZbRZwpGOSsJc5yDvKmerchant-icon-356788-cwlogo.png',
      key: this.props.stripePublishable,
      locale: 'auto',
      panelLabel: 'Subscribe',
      token: onStripeTokenSet,
    })

    this.checkout.open({
      name: "Jobs @ coderwall.com",
      description: "Monthly subscription",
      amount: this.props.cost,
    })
  }

  handleChange(input, e) {
    const val = e.target.value
    this.setState({ [input]: val })

    if (input === 'companyLogo') {
      this.testImage(val, (url, result) => {
        if (result === 'success') {
          this.setState({ validLogoUrl: url })
        } else {
          this.setState({ validLogoUrl: null })
        }
      })
    }
  }

  handleBlur(e) {
    const match = e.target.name.match(/\[(.*)\]/)
    if (!match) { return }

    const field = match[1]
    if (field && requiredFields.indexOf(field) !== -1) {
      if (!this.state[field]) {
        this.setState({ brokenFields: { ...this.state.brokenFields, [field]: true } })
      } else {
        const withoutField = Object.assign({}, this.state.brokenFields)
        delete withoutField[field]
        this.setState({ brokenFields: withoutField })
      }
    }
  }

  validateFields() {
    let brokenFields = requiredFields.filter(f => !this.state[f])
    if (this.state.companyLogo && !this.state.validLogoUrl) {
      brokenFields = [...brokenFields, 'companyLogo']
    }
    this.setState({ brokenFields: brokenFields.reduce((memo, i) => ({ ...memo, [i]: true }), {}) })
    return brokenFields.length === 0
  }

  testImage(url, callback, timeout) {
    timeout = timeout || 5000
    let timedOut = false, timer
    const img = new Image()
    img.onerror = img.onabort = function () {
      if (!timedOut) {
        clearTimeout(timer)
        callback(url, "error")
      }
    }
    img.onload = function () {
      if (!timedOut) {
        clearTimeout(timer)
        callback(url, "success")
      }
    }
    img.src = url
    timer = setTimeout(() => {
      timedOut = true
      callback(url, "timeout")
    }, timeout)
  }
}
