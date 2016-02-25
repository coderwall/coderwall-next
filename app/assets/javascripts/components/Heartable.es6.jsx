class Heartable extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      hearted: false,
      count: this.props.initialCount,
    }
  }

  componentDidMount() {
    document.current_user_likes.when_liked(this.props.id, (likes) => {
      this.setState({hearted: true})
    })
  }

  render() {
    return (
      <Heart count={this.state.count}
             hearted={this.state.hearted}
             onClick={() => this.handleClick()}
             layout={this.props.layout} />
    )
  }

  handleClick() {
    if (this.state.hearted) { return }

    this.setState({
      hearted: true,
      count: this.props.initialCount + 1
    })
    $.ajax({
      url: this.props.href,
      method: 'POST',
      error: (xhr) => {
        this.setState({hearted: false, count: this.props.initialCount})
        promptUserSignInOn401(xhr)}
    })
  }
}

Heartable.propTypes = {
  initialCount: React.PropTypes.number,
  protipId: React.PropTypes.string
}
