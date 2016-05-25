let messageId = 1

class Chat extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      comments: props.comments
    }
  }

  render() {
    return (
      <div className="flex flex-column ml3 bg-white rounded">
        <div ref="scrollable" className="flex-auto overflow-scroll border-top p1" id="chat" style={{maxHeight: 380, minHeight: 379}}>
          <div className="diminish py1 center">Start of discussion</div>
          <div className="clearfix" id="comments">
            {this.renderComments()}
          </div>
        </div>
        <div className="flex-last mt2">
          {this.renderChatInput()}
        </div>
      </div>
    )
  }

  renderComments() {
    return this.state.comments.map(c =>
      <ChatComment
        key={c.id}
        authorUrl={c.authorUrl}
        authorUsername={c.authorUsername}
        markup={c.markup} />
    )
  }

  renderChatInput() {
    if (this.props.signedIn) {
      return (
        <form onSubmit={this.handleSubmit.bind(this)}>
          <input type="text" ref="body" defaultValue="" placeholder="Ask question" className="col-9 focus-no-border font-sm resize-chat-on-change m0" style={{"border": "none", "outline": "none"}} />
          <div className="right col-3 m0">
            <button className="btn m0 right bg-green white" type="submit" style={{height: "100%"}}>
              Send
            </button>
          </div>
        </form>
      )
    } else {
      return (
        <div className="clearfix border rounded p0 m0 bg-white">
          <div className="col font-sm gray p1">
            Commenting disabled
          </div>
          <button className="right btn m0 right bg-gray silver" disabled>
            <i className="fa fa-lock mr1" />
            Send
          </button>
        </div>
      )
    }
  }

  handleSubmit(e) {
    e.preventDefault()
    const clientId = `client-${messageId++}`
    $.ajax({
      url: '/comments',
      method: 'POST',
      dataType: 'json',
      data: {
        socket_id: pusher.connection.socket_id,
        comment: {
          article_id: this.props.stream.id,
          body: this.refs.body.value,
        },
      },
      success: (data) => {
        const comments = this.state.comments
        const comment = comments.find(c => c.id === clientId)
        comment.id = data.id
        comment.markup = data.markup
        this.setState({comments: comments})
      }
    })
    this.setState({comments: [...this.state.comments, {
      id: clientId,
      authorUrl: this.props.authorUrl,
      authorUsername: this.props.authorUsername,
      markup: window.marked(this.refs.body.value),
    }]})
    this.refs.body.value = ''
  }

  componentDidMount() {
    window.channel.bind('new-comment', comment => {
      this.setState({comments: [...this.state.comments, comment]})
    })

    $(this.refs.scrollable).bind('mousewheel DOMMouseScroll', function(e) {
      const d = e.originalEvent.wheelDelta || -e.originalEvent.detail
      const stop = d > 0 ? this.scrollTop === 0 : this.scrollTop > this.scrollHeight - this.offsetHeight
      if (stop) {
        return e.preventDefault();
      }
    })
    this.scrollToBottom()
  }

  componentWillUnmount() {
    $(this.refs.scrollable).unbind('mousewheel DOMMouseScroll')
  }

  componentDidUpdate(prevState) {
    if (prevState.comments.length < this.state.comments.length) {
      this.scrollToBottom()
    }
  }

  scrollToBottom() {
    $(this.refs.scrollable).scrollTop($(this.refs.scrollable).prop("scrollHeight"))
  }
}

Chat.propTypes = {
  stream: React.PropTypes.object.isRequired,
  comments: React.PropTypes.array.isRequired,
  signedIn: React.PropTypes.bool,
  isLive: React.PropTypes.bool,
}
