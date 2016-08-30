const requiredFields = [
  'author_email',
  'author_name',
  'company',
  'company_url',
  'location',
  'source',
  'title',
]

class NewJob extends React.Component {
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
        <form ref="form" action="/jobs" acceptCharset="UTF-8" method="post"
          onSubmit={e => this.handleSubmit(e)}
          onBlur={e => this.handleBlur(e)}>
          <input name="utf8" type="hidden" defaultValue="✓" />
          <input type="hidden" name="authenticity_token" defaultValue={csrfToken} />
          <input type="hidden" name="stripeToken" value={this.state.stripeToken} />

          <label htmlFor="job_title">Job Title</label>
          <input id="job_title" value={this.state.title} onChange={e => this.handleChange('title', e)} type="text" className={this.fieldClasses('title')} name="job[title]" placeholder="Sr. Frontend Engineer" />

          <label htmlFor="job_company">Company Name</label>
          <input id="job_company" value={this.state.company} onChange={e => this.handleChange('company', e)} type="text" className={this.fieldClasses('company')} name="job[company]" placeholder="Acme Inc" />

          <label htmlFor="job_location">Location</label>
          <input id="job_location" value={this.state.location} onChange={e => this.handleChange('location', e)} type="text" className={this.fieldClasses('location')} name="job[location]" placeholder="Chicago, Il" />

          <label htmlFor="job_source">Link to your job description</label>
          <input id="job_source" value={this.state.source} onChange={e => this.handleChange('source', e)} type="text" className={this.fieldClasses('source')} name="job[source]" placeholder="https://acme.inc/jobs/78" />

          <label htmlFor="job_company_url">Company Website</label>
          <input id="job_company_url" value={this.state.company_url} onChange={e => this.handleChange('company_url', e)} type="text" className={this.fieldClasses('company_url')} name="job[company_url]" placeholder="https://acme.inc" />

          <div className="clearfix">
            <div className="col col-8">
              <label htmlFor="job_company_logo">Company Logo (optional)</label>
              <input id="job_company_logo" value={this.state.companyLogo} onChange={e => this.handleChange('companyLogo', e)} type="text" className={this.fieldClasses('companyLogo')} name="job[company_logo]" placeholder="https://acme.inc/logo.png" />
            </div>

            <div className="col col-4 px2">
              <img src={this.state.validLogoUrl} style={{ width: 200, height: 200, objectFit: 'cover'}} />
            </div>
          </div>

          <label htmlFor="job_author_name">Contact Name</label>
          <input id="job_author_name" value={this.state.author_name} onChange={e => this.handleChange('author_name', e)} type="text" className={this.fieldClasses('author_name')} name="job[author_name]" placeholder="Your name" />

          <label htmlFor="job_author_email">Contact Email</label>
          <input id="job_author_email" value={this.state.author_email} onChange={e => this.handleChange('author_email', e)} type="email" className={this.fieldClasses('author_email')} name="job[author_email]" placeholder="Your email for the receipt" />

          <div className="col-12">
            <input id="role_type_full_time" name="job[role_type]" type="radio" defaultValue="Full Time" defaultChecked />
            <label htmlFor="role_type_full_time">Full Time</label>
            <input id="role_type_part_time" name="job[role_type]" type="radio" defaultValue="Part Time" />
            <label htmlFor="role_type_part_time">Part Time</label>
            <input id="role_type_part_time" name="job[role_type]" type="radio" defaultValue="Contract" />
            <label htmlFor="role_type_part_time">Contract</label>
          </div>

          <div class='center'>
            <button
              className={`btn rounded mt3 white px4 py2 ${submittable ? 'bg-green' : 'bg-gray'}`}
              type="submit"
              disabled={!submittable}>
              Complete Posting Job for $299
            </button>
          </div>

        </form>
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
      key: this.props.stripePublishable,
      image: 'https://s3.amazonaws.com/stripe-uploads/A6CJ1PO8BNz85yiZbRZwpGOSsJc5yDvKmerchant-icon-356788-cwlogo.png',
      locale: 'auto',
      token: onStripeTokenSet,
      closed: onClosed,
    })

    this.checkout.open({
      name: "Jobs @ coderwall.com",
      description: "30 day listing",
      amount: this.props.cost,
    })
  }

  handleChange(input, e) {
    const val = e.target.value
    this.setState({[input]: val})

    if (input === 'companyLogo') {
      this.testImage(val, (url, result) => {
        if (result === 'success') {
          this.setState({ validLogoUrl: url})
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
        this.setState({ brokenFields: {...this.state.brokenFields, [field]: true } })
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
    this.setState({ brokenFields: brokenFields.reduce((memo, i) => ({...memo, [i]: true}), {}) })
    return brokenFields.length === 0
  }

  testImage(url, callback, timeout) {
    timeout = timeout || 5000
    var timedOut = false, timer
    var img = new Image()
    img.onerror = img.onabort = function() {
      if (!timedOut) {
        clearTimeout(timer)
        callback(url, "error");
      }
    }
    img.onload = function() {
      if (!timedOut) {
        clearTimeout(timer)
        callback(url, "success")
      }
    }
    img.src = url
    timer = setTimeout(function() {
      timedOut = true
      callback(url, "timeout")
    }, timeout)
  }
}


NewJob.propTypes = {
  cost: React.PropTypes.number.isRequired,
  stripePublishable: React.PropTypes.string.isRequired
}
