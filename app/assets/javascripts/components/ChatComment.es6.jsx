class ChatComment extends React.Component {
  render() {
    return (
      <div className="comment inline-block py1" style={{width: '100%'}}>
        <div className="left mt1 mr2 avatar small" style={{backgroundColor: '#913894'}}>
        </div>
        <div className="overflow-hidden py0 mt0">
          <div className="clearfix">
            <div className="author">
              <a className="bold black no-hover" href={this.props.authorUrl}>
                {this.props.authorUsername}
              </a>
            </div>
            <div className="content small" dangerouslySetInnerHTML={{__html: this.props.markup}}></div>
          </div>
        </div>
      </div>
    )
  }
}

ChatComment.propTypes = {
  authorUrl: React.PropTypes.string.isRequired,
  authorUsername: React.PropTypes.string.isRequired,
  markup: React.PropTypes.string.isRequired,
}
