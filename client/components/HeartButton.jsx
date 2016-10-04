import React, { PropTypes as T } from 'react'
import { connect } from 'react-redux'
import Heart from './Heart'
import { heart } from '../actions/heartActions'

class HeartButton extends React.Component {
  static propTypes = {
    count: T.number,
    currentUser: T.object,
    dispatch: T.func.isRequired,
    heartableId: T.string,
    hearted: T.bool,
    href: T.string.isRequired,
    labels: T.arrayOf(T.string),
  }

  render() {
    return (
      <Heart
        hearted={this.props.hearted}
        labels={this.props.labels}
        onClick={() => this.handleClick()}
        count={this.props.count} />
    )
  }

  handleClick() {
    if (this.props.hearted) { return }

    this.props.dispatch(
      heart(
        this.props.href,
        this.props.heartableId,
        this.props.currentUser && this.props.currentUser.id
      )
    )
  }
}

function mapStateToProps(state, ownProps) {
  const heartables = [
    ...(state.protips.items || []),
    ...(state.comments.items || []),
    state.currentProtip.item,
  ]

  const heartable = heartables.find(p => p.heartableId === ownProps.heartableId)

  if (!heartable) { return {} }

  const hearts = state.hearts.items || []
  const hearted = hearts.indexOf(ownProps.heartableId) > -1

  return {
    hearted,
    count: heartable.hearts,
  }
}

export default connect(mapStateToProps)(HeartButton)
