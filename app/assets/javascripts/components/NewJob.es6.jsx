const requiredFields = [
  'authorEmail',
  'authorName',
  'company',
  'companyLogo',
  'companyUrl',
  'location',
  'source',
  'title',
]

class NewJob extends React.Component {
  constructor(props) {
    super(props)
    this.state = { brokenFields: {} }
    this.checkout = StripeCheckout.configure({
      key: props.stripePublishable,
      image: 'https://s3.amazonaws.com/stripe-uploads/A6CJ1PO8BNz85yiZbRZwpGOSsJc5yDvKmerchant-icon-356788-cwlogo.png',
      locale: 'auto',
      token: token => {
        this.setState({ saving: true, stripeToken: token.id }, () => this.refs.form.getDOMNode().submit())
      }
    });
  }

  componentDidMount() {
    $(window).on('popstate', function() {
      this.checkout.close()
    })
  }

  render() {
    const csrfToken = document.getElementsByName('csrf-token')[0].content

    return (
        <form ref="form" action="/jobs" acceptCharset="UTF-8" method="post" onSubmit={e => this.handleSubmit(e)}>
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
          <input id="job_company_url" value={this.state.companyUrl} onChange={e => this.handleChange('companyUrl', e)} type="text" className={this.fieldClasses('companyUrl')} name="job[company_url]" placeholder="https://acme.inc" />

          <div className="clearfix">
            <div className="col col-8">
              <label htmlFor="job_company_logo">Company Logo (optional)</label>
              <input id="job_company_logo" value={this.state.companyLogo} onChange={e => this.handleChange('companyLogo', e)} type="text" className={this.fieldClasses('companyLogo')} name="job[company_logo]" placeholder="https://acme.inc/logo.png" />
            </div>

            <div className="col col-4 px2">
              <img src={this.state.validLogoUrl} />
            </div>
          </div>

          <label htmlFor="job_author_name">Contact Name</label>
          <input id="job_author_name" value={this.state.authorName} onChange={e => this.handleChange('authorName', e)} type="text" className={this.fieldClasses('authorName')} name="job[author_name]" placeholder="Your name" />

          <label htmlFor="job_author_email">Contact Email</label>
          <input id="job_author_email" value={this.state.authorEmail} onChange={e => this.handleChange('authorEmail', e)} type="email" className={this.fieldClasses('authorEmail')} name="job[author_email]" placeholder="Your email for the receipt" />

          <div className="col-12">
            <input id="role_type_full_time" name="job[role_type]" type="radio" value="Full Time" defaultChecked />
            <label htmlFor="role_type_full_time">Full Time</label>
            <input id="role_type_part_time" name="job[role_type]" type="radio" value="Part Time" />
            <label htmlFor="role_type_part_time">Part Time</label>
            <input id="role_type_part_time" name="job[role_type]" type="radio" value="Contract" />
            <label htmlFor="role_type_part_time">Contract</label>
          </div>

          <div class='center'>
            <button className={`btn rounded mt3 white px4 py2 ${this.state.saving ? 'bg-gray' : 'bg-green'}`} type="submit" disabled={this.state.saving}>
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
    console.log('ON SUBMIHT')
    e.preventDefault()

    let brokenFields = requiredFields.filter(f => !this.state[f])
    if (!this.state.validLogoUrl) {
      brokenFields = [...brokenFields, 'companyLogo']
    }
    this.setState({ brokenFields: brokenFields.reduce((memo, i) => ({...memo, [i]: true}), {}) })
    if (brokenFields.length > 0) { return }

    this.checkout.open({
      name: "Jobs @ coderwall.com",
      description: "30 day listing",
      amount: this.props.cost,
    })
  }

  handleChange(input, e) {
    this.setState({[input]: e.target.value})

    if (input === 'companyLogo') {
      this.testImage(e.target.value, (url, result) => {
        if (result === 'success') {
          this.setState({ validLogoUrl: url})
        } else {
          this.setState({ validLogoUrl: null })
        }
      })
    }
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
