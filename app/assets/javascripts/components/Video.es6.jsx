let id = 1

class Video extends React.Component {
  constructor(props) {
    super(props)
    this.componentId = `video-${id++}`
    this.state = {
      showStatus: false,
      online: null,
    }
  }

  componentDidMount() {
    window.jwplayer.key = this.props.jwplayerKey
    this.jwplayer = window.jwplayer(this.componentId)
    this.jwplayer.setup({
      sources: [{
        file: this.props.source
      }],
      image: this.props.offlineImage,
      stretching: "fill",
      captions: {
        color: "FFCC00",
        backgroundColor: "000000",
        backgroundOpacity: 50
      }
    }).on('play', () => this.setState({online: true}))
      .on('bufferFull', () => this.setState({online: true}))
      .on('resize', data => $(window).trigger('video-resize', data))
      .on('time', data => $(window).trigger('video-time', data))
      .onError(this.onError.bind(this))

    // debug
    // this.jwplayer.on('all', this.onAll.bind(this))
  }

  componentWillUnmount() {
    this.jwplayer.remove()
  }

  render() {
    return (
      <div>
        {this.props.showStatus && this.renderOnlineStatus()}

        <div className={this.state.online === false && 'hide'}>
          <div id={this.componentId}></div>
        </div>
        {this.state.online === false && this.renderOffline()}
      </div>
    )
  }

  renderOffline() {
    return (
      <div style={{height: this.state.playerHeight, backgroundColor: 'black'}}>
        <img src={this.props.offlineImage}  />
      </div>
    )
  }

  renderOnlineStatus() {
    const message = this.state.online ? 'Connected, previewing stream' : 'No stream detected, preview unavailable'

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

  onError(e) {
    setTimeout(() => this.jwplayer.load(this.props.source).play(true), 2000)
    if (this.state.online === false) { return }
    // console.log('jwplayer error', e)
    this.setState({online: false, playerHeight: document.getElementById(this.componentId).clientHeight})
  }

  onAll(e, data) {
    // if (e !== 'time' && e !== 'meta') {
      console.log(e, data)
    // }
  }
}

Video.propTypes = {
  jwplayerKey: React.PropTypes.string.isRequired,
  offlineImage: React.PropTypes.string.isRequired,
  showStatus: React.PropTypes.bool,
  source: React.PropTypes.string.isRequired,
}
