class Heart extends React.Component {
  render() {
    return (
      <div>
        <a className="heart left ml1 mr2" data-method="post" data-remote="true" href="#">
          {this.renderHeartState()}
          <div className="center highlight hearted hide">
            <i className="fa fa-heart" />
          </div>
          <div className="center font-tiny diminish">
            {this.numberToHuman(this.props.count)}
          </div>
        </a>
      </div>
    )
  }

  renderHeartState() {
    if (!this.props.hearted) {
      return <div className="center highlight">
        <i className="fa fa-heart-o" />
      </div>
    }
    return <div className="center highlight hearted">
      <i className="fa fa-heart" />
    </div>
  }

  numberToHuman(number) {
    const s = ['', 'k', 'M']
    var e = Math.floor(Math.log(number) / Math.log(1000))
    return (number / Math.pow(1000, e)).toFixed(2) + s[e]
  }
}

Heart.propTypes = {
  hearted: React.PropTypes.bool,
  count: React.PropTypes.number
}
