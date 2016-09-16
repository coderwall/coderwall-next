/* global $, document, promptUserSignInOn401 */
import React, { PropTypes as T } from 'react'
import Heart from './Heart'

export default class Heartable extends React.Component {
  static propTypes = {
    id: T.string,
    initialCount: T.number,
    layout: T.string,
    protipId: T.string,
    href: T.string,
  }

  constructor(props) {
    super(props)
    this.state = {
      hearted: false,
      count: this.props.initialCount,
    }
  }

  render() {
    return (
      <Heart
        count={this.state.count}
        hearted={this.state.hearted}
        onClick={() => this.handleClick()}
        layout={this.props.layout} />
    )
  }

  componentDidMount() {
    document.current_user_likes.when_liked(this.props.id, () => {
      this.setState({ hearted: true })
    })
  }

  handleClick() {
    if (this.state.hearted) { return }

    this.setState({
      hearted: true,
      count: this.props.initialCount + 1,
    })
    $.ajax({
      url: this.props.href,
      method: 'POST',
      error: (xhr) => {
        this.setState({ hearted: false, count: this.props.initialCount })
        promptUserSignInOn401(xhr)
      },
    })
  }
}
