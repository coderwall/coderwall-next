/* global ga */
import React, { Component, PropTypes as T } from 'react'

export default class TrackClick extends Component {
  static propTypes = {
    action: T.string.isRequired,
    category: T.string.isRequired,
    children: T.node.isRequired,
    label: T.string.isRequired,
  }

  render() {
    return <div onClick={this.handleClick}>{this.props.children}</div>
  }

  handleClick = () => {
    ga('send', 'event', {
      eventCategory: this.props.category,
      eventAction: this.props.action,
      eventLabel: this.props.label,
      transport: 'beacon',
    })
  }
}
