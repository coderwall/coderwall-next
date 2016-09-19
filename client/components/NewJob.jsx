/* global alert, window, document, Image, StripeCheckout */
import React, { Component, PropTypes as T } from 'react'
import { connect } from 'react-redux'

import JobForm from './JobForm'

import { createPost } from '../actions/jobActions'

class NewJob extends Component {
  static propTypes = {
    cost: T.number.isRequired,
    dispatch: T.func.isRequired,
    error: T.string,
    job: T.object,
    stripePublishable: T.string.isRequired,
  }

  render() {
    return <JobForm onSubmit={this.handleSubmit} />
  }

  componentDidUpdate(prevProps) {
    if (!prevProps.job && this.props.job && this.props.job.id) {
      window.location = `/jobs?posted=${this.props.job.id}`
    }

    if (!prevProps.error && this.props.error) {
      alert("Unable to charge this card. Please try again") // eslint-disable-line no-alert
    }
  }

  handleSubmit = (values) => new Promise((resolve) => {
    const onStripeTokenSet = token => this.props.dispatch(createPost(token.id, values))

    this.checkout = this.checkout || StripeCheckout.configure({
      key: this.props.stripePublishable,
      image: 'https://s3.amazonaws.com/stripe-uploads/A6CJ1PO8BNz85yiZbRZwpGOSsJc5yDvKmerchant-icon-356788-cwlogo.png',
      locale: 'auto',
      token: onStripeTokenSet,
      closed: resolve,
    })

    this.checkout.open({
      name: "Jobs @ coderwall.com",
      description: "30 day listing",
      amount: this.props.cost,
    })
  })
}

const mapStateToProps = (state) => ({
  job: state.job.item,
  error: state.job.error,
})

export default connect(mapStateToProps)(NewJob)
