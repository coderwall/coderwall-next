import React, { Component, PropTypes as T } from 'react'
import { connect } from 'react-redux'

import ToggleWithLabel from './ToggleWithLabel'
import { subscribe, mute } from '../actions/protipActions'

class ProtipSubscribeButton extends Component {
  static propTypes = {
    currentUser: T.object,
    dispatch: T.func.isRequired,
    protipId: T.string,
    subscribed: T.bool,
  }

  render() {
    return (
      <ToggleWithLabel
        iconOff="bell-slash-o"
        iconOn="bell-o"
        labelOff="Update Notifications Off"
        labelOn="Update Notifications On"
        on={this.props.subscribed}
        onClick={this.handleClick} />
    )
  }

  handleClick = () => {
    const action = this.props.subscribed ? mute : subscribe
    this.props.dispatch(
      action(this.props.protipId, this.props.currentUser && this.props.currentUser.id)
    )
  }
}

function mapStateToProps(state) {
  let subscribed = false
  const protip = state.currentProtip.item
  const currentUser = state.currentUser.item
  if (currentUser) {
    subscribed = protip.subscribers.indexOf(currentUser.id) !== -1
  }

  return {
    protipId: protip.public_id,
    subscribed,
  }
}

export default connect(mapStateToProps)(ProtipSubscribeButton)
