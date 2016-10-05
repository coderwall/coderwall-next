/* global document, fetch, window, Pusher */

import React, { PropTypes as T } from 'react'
import ChatComment from './ChatComment'

let messageId = 1

function pollUntil(condition, action, interval = 100) {
  if (!condition()) {
    setTimeout(() => pollUntil(condition, action, interval), interval)
    return
  }

  action()
}


export default class Chat extends React.Component {
  static propTypes = {
    authorUrl: T.string.isRequired,
    authorUsername: T.string.isRequired,
    chatChannel: T.string.isRequired,
    comments: T.array.isRequired,
    layout: T.string.isRequired,
    pusherKey: T.string.isRequired,
    signedIn: T.bool,
    stream: T.object.isRequired,
  }

  constructor(props) {
    super(props)
    this.state = {
      moreComments: true,
      comments: props.comments,
    }
  }

  render() {
    let cx = "flex flex-column bg-white rounded"
    if (this.props.layout === 'popout') {
      cx += " full-height"
    }
    return (
      <div className={cx}>
        {this.renderHeader()}
        <div
          ref={c => { this.scrollable = c }}
          className="flex flex-auto flex-column overflow-y-scroll border-top p1 js-video-height"
          id="comments">
          {this.state.moreComments ||
            <div className="diminish py1 center">Start of discussion</div>}
          {this.renderComments()}
        </div>
        <div className="flex-last clearfix border rounded p0 m0 bg-white">
          {this.renderChatInput()}
        </div>
      </div>
    )
  }

  componentWillMount() {
    pollUntil(
      () => typeof Pusher !== 'undefined',
      () => {
        const pusher = new Pusher(this.props.pusherKey)
        const channel = pusher.subscribe(this.props.chatChannel)
        channel.bind('new-comment', comment => {
          this.setState({ comments: [...this.state.comments, comment] })
        })

        this.setState({ pusher, channel })
      }
    )
  }

  componentDidMount() {
    this.scrollable.addEventListener('wheel', this.handleScroll)
    this.scrollToBottom()
    this.fetchOlderChatMessages()
    window.addEventListener('video-resize', this.constrainChatToStream)
    window.addEventListener('video-time', this.handleVideoTime)
  }

  componentWillUpdate() {
    const node = this.scrollable
    this.shouldScrollBottom = node.scrollTop + node.offsetHeight >= node.scrollHeight
    this.scrollHeight = node.scrollHeight
    this.scrollTop = node.scrollTop
  }

  componentDidUpdate(prevState) {
    if (prevState.comments.length < this.state.comments.length) {
      if (this.shouldScrollBottom) {
        this.scrollToBottom()
      } else {
        const node = this.scrollable
        node.scrollTop = this.scrollTop + (node.scrollHeight - this.scrollHeight)
      }
    }
  }

  componentWillUnmount() {
    this.scrollable.removeEventListener('wheel', this.handleScroll)
    window.removeEventListener('video-resize', this.constrainChatToStream)
    window.removeEventListener('video-time', this.handleVideoTime)
  }

  renderHeader() {
    if (this.props.layout !== 'popout') { return null }

    return (
      <div className="flex flex-row px1 py2">
        <div className="h4 flex-auto bold">
          <a href={this.props.stream.url} target="_new">
            {this.props.stream.title}
          </a>
        </div>
        <div className="h4 diminish">
          <i className="fa fa-eye px1" />
          <span id="js-live-viewers" />
        </div>

      </div>
    )
  }

  renderComments() {
    let visibleComments = this.state.comments
    if (!this.props.stream.active) {
      const start = this.props.stream.recording_started_at
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
        <form onSubmit={this.handleSubmit}>
          <input
            type="text"
            ref={c => { this.body = c }}
            defaultValue=""
            placeholder="Ask question"
            className="col-9 focus-no-border font-sm resize-chat-on-change m0"
            style={{ border: "none", outline: "none" }} />
          <div className="right col-3 m0">
            <button
              className="btn m0 right bg-green white" type="submit" style={{ height: "100%" }}>
              Send
            </button>
          </div>
        </form>
      )
    }
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

  handleSubmit = (e) => {
    e.preventDefault()
    const clientId = `client-${messageId++}`
    fetch('/comments.json', {
      method: 'POST',
      body: JSON.stringify({
        socket_id: this.state.pusher.connection.socket_id,
        comment: {
          article_id: this.props.stream.id,
          body: this.body.value,
        },
      }),
    }).then(resp => resp.json()).then(data => {
      const comments = this.state.comments
      const comment = comments.find(c => c.id === clientId)
      comment.id = data.id
      comment.markup = data.markup
      this.setState({ comments })
    })
    this.setState({ comments: [...this.state.comments, {
      id: clientId,
      authorUrl: this.props.authorUrl,
      authorUsername: this.props.authorUsername,
      markup: window.marked(this.body.value),
    }] })
    this.body.value = ''
  }

  handleScroll = (e) => {
    if (this.scrollTop < 100) {
      this.fetchOlderChatMessages()
    }
    const d = e.originalEvent.wheelDelta || -e.originalEvent.detail
    const stop = d > 0 ?
      this.scrollTop === 0 :
      this.scrollTop > this.scrollHeight - this.offsetHeight
    if (stop) {
      return e.preventDefault()
    }
    return true
  }

  handleVideoTime = (e, data) => this.setState({ timeOffset: data.position })

  fetchOlderChatMessages() {
    if (this.state.fetching || !this.state.moreComments) {
      return
    }
    const before = this.state.comments.length > 0 ? this.state.comments[0].created_at : null
    this.setState({ fetching: true })
    fetch(`/comments.json?article_id=${this.props.stream.id}&before=${before}`, {
      method: 'GET',
    }).then(resp => resp.json()).then(data => {
      const existing = this.state.comments.map(c => c.id)
      this.setState({
        fetching: false,
        moreComments: data.comments.length === 10,
        comments: [
          ...data.comments.reverse().filter(a => existing.indexOf(a.id) === -1),
          ...this.state.comments,
        ],
      })
    })
  }

  scrollToBottom() {
    this.scrollable.scrollTop = this.scrollable.scrollHeight
  }

  constrainChatToStream(e, data) {
    const anchorHeight = data.height
    const el = document.querySelector('.js-video-height')
    el.style.minHeight = el.style.maxHeight = anchorHeight - 47
  }
}
