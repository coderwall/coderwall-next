/* global CustomEvent, document, window */
import React, { PropTypes as T } from 'react'

let id = 1

export default class Video extends React.Component {
  static propTypes = {
    jwplayerKey: T.string.isRequired,
    mute: T.bool,
    offlineImage: T.string.isRequired,
    showStatus: T.bool,
    sources: T.array.isRequired,
  }

  constructor(props) {
    super(props)
    this.componentId = `video-${id++}`
    this.state = {
      showStatus: false,
      online: null,
    }
  }

  render() {
    return (
      <div>
        {this.props.showStatus && this.renderOnlineStatus()}

        <div className={this.state.online === false && 'hide'}>
          <div id={this.componentId} />
        </div>
        {this.state.online === false && this.renderOffline()}
      </div>
    )
  }

  componentDidMount() {
    window.jwplayer.key = this.props.jwplayerKey
    this.jwplayer = window.jwplayer(this.componentId)
    this.jwplayer.setup({
      sources: this.props.sources,
      image: this.props.offlineImage,
      stretching: "fill",
      captions: {
        color: "FFCC00",
        backgroundColor: "000000",
        backgroundOpacity: 50,
      },
      mute: !!this.props.mute,
    }).on('play', () => this.setState({ online: true })).
      on('bufferFull', () => this.setState({ online: true })).
      on('resize', data => this.triggerCustom('video-resize', data)).
      on('time', data => this.triggerCustom('video-time', data)).
      onError(this.onError.bind(this))

    // debug
    // this.jwplayer.on('all', this.onAll.bind(this))
  }

  componentWillUnmount() {
    this.jwplayer.remove()
  }

  renderOffline() {
    return (
      <div style={{ height: this.state.playerHeight, backgroundColor: 'black' }}>
        <img alt="offline" src={this.props.offlineImage} />
      </div>
    )
  }

  renderOnlineStatus() {
    const message = this.state.online ?
      'Connected, previewing stream' :
      'No stream detected, preview unavailable'

    return (
      <div className="border-box p2 border-right border-left">
        <div className="clearfix">
          <div className="col col-8 py1">
            <h3 className="mt0 mb0 inline mr2">
              <i className={`fa fa-video-camera mr1 ${this.state.online && 'green'}`} />
              {message}
            </h3>
          </div>
          <div className="col col-4" />
        </div>
      </div>
    )
  }

  onError() {
    setTimeout(() => this.jwplayer.load(this.props.sources).play(true), 2000)
    if (this.state.online === false) { return }
    // console.log('jwplayer error', e)
    this.setState({
      online: false,
      playerHeight: document.getElementById(this.componentId).clientHeight,
    })
  }

  onAll(e, data) {
    // if (e !== 'time' && e !== 'meta') {
    console.log(e, data) // eslint-disable-line no-console
    // }
  }

  triggerCustom(e, data) {
    let event
    if (window.CustomEvent) {
      event = new CustomEvent(e, data)
    } else {
      event = document.createEvent('CustomEvent')
      event.initCustomEvent(e, true, true, data)
    }

    window.dispatchEvent(event)
  }
}
