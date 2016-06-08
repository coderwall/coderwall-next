let messageId = 1

function pollUntil(condition, action, interval=100) {
  if (!condition()) {
    return setTimeout(() => pollUntil(condition, action, interval), interval)
  }

  action()
}


class Chat extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      moreComments: true,
      comments: props.comments,
    }
  }

  render() {
    return (
      <div className="flex flex-column ml3 bg-white rounded">
        <div ref="scrollable" className="flex-auto overflow-y-scroll border-top p1" id="chat" style={{maxHeight: 380, minHeight: 379}}>
          {this.state.moreComments || <div className="diminish py1 center">Start of discussion</div>}
          <div className="clearfix" id="comments">
            {this.renderComments()}
          </div>
        </div>
        <div className="flex-last clearfix border rounded p0 m0 bg-white">
          {this.renderChatInput()}
        </div>
      </div>
    )
  }

  renderComments() {
    let visibleComments = this.state.comments
    const start = this.props.stream.recording_started_at
    if (start) {
      const current = start + this.state.timeOffset
      visibleComments = this.state.comments.filter(c => c.created_at < current)
    }
    return visibleComments.map(c =>
      <ChatComment
        key={c.id}
        id={c.id}
        authorUrl={c.authorUrl}
        authorUsername={c.authorUsername}
        markup={c.markup} />
    )
  }

  renderChatInput() {
    const allowChat = this.props.signedIn &&
      this.state.channel &&
      this.props.stream.archived_at === null

    if (allowChat) {
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
        <div>
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
        socket_id: this.state.pusher.connection.socket_id,
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

  fetchOlderChatMessages() {
    if (this.state.fetching || !this.state.moreComments) {
      return
    }
    const before = this.state.comments.length > 0 ? this.state.comments[0].created_at : null
    this.setState({fetching: true})
    $.ajax({
      url: '/comments',
      method: 'GET',
      dataType: 'json',
      data: {
        article_id: this.props.stream.id,
        before,
      },
      success: (data) => {
        const existing = this.state.comments.map(c => c.id)
        this.setState({
          fetching: false,
          moreComments: data.comments.length == 10,
          comments: [
            ...data.comments.reverse().filter(a => existing.indexOf(a.id) === -1),
            ...this.state.comments
          ]
        })
      }
    })
  }

  componentWillMount() {
    pollUntil(
      () => typeof Pusher !== 'undefined',
      () => {
        const pusher = new Pusher(this.props.pusherKey)
        const channel = pusher.subscribe(this.props.chatChannel)
        channel.bind('new-comment', comment => {
          this.setState({comments: [...this.state.comments, comment]})
        })

        this.setState({pusher, channel})
      }
    )
  }

  componentDidMount() {
    const self = this
    $(this.refs.scrollable).bind('mousewheel DOMMouseScroll', function(e) {
      if (this.scrollTop < 100) {
        self.fetchOlderChatMessages()
      }
      const d = e.originalEvent.wheelDelta || -e.originalEvent.detail
      const stop = d > 0 ? this.scrollTop === 0 : this.scrollTop > this.scrollHeight - this.offsetHeight
      if (stop) {
        return e.preventDefault();
      }
    })
    this.scrollToBottom()
    this.fetchOlderChatMessages()
    $(window).on('video-resize', this.constrainChatToStream)
    $(window).on('video-time', (e, data) => this.setState({ timeOffset: data.position }))
  }

  componentWillUnmount() {
    $(this.refs.scrollable).unbind('mousewheel DOMMouseScroll')
  }

  componentWillUpdate() {
    const node = this.refs.scrollable
    this.shouldScrollBottom = node.scrollTop + node.offsetHeight >= node.scrollHeight
    this.scrollHeight = node.scrollHeight
    this.scrollTop = node.scrollTop
  }

  componentDidUpdate(prevState) {
    if (prevState.comments.length < this.state.comments.length) {
      if (this.shouldScrollBottom) {
        this.scrollToBottom()
      } else {
        const node = this.refs.scrollable
        node.scrollTop = this.scrollTop + (node.scrollHeight - this.scrollHeight)
      }
    }
  }

  scrollToBottom() {
    $(this.refs.scrollable).scrollTop($(this.refs.scrollable).prop("scrollHeight"))
  }

  constrainChatToStream(e, data) {
    const anchorHeight = data.height
    $('#chat').css('min-height', anchorHeight - 47)
    $('#chat').css('max-height', anchorHeight - 47)
  }
}

Chat.propTypes = {
  chatChannel: React.PropTypes.string.isRequired,
  comments: React.PropTypes.array.isRequired,
  pusherKey: React.PropTypes.string.isRequired,
  signedIn: React.PropTypes.bool,
  stream: React.PropTypes.object.isRequired,
}
