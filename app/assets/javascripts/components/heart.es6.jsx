class Heart extends React.Component {
  render() {
    let classes = {
      root: 'heart left ml1 mr2 pointer',
      icon: 'highlight center',
      count: 'diminish center font-tiny'
    }
    if (this.props.layout === 'inline') {
      classes = {
        root: 'heart left ml1 mr2 pointer flat',
        icon: 'highlight mr1',
        count: 'diminish inline'
      }
    }
    return (
      <div>
        <a className={classes.root} onClick={() => this.props.onClick()}>
          {this.renderHeartState(classes.icon)}
          <div className={classes.count}>
            {this.numberToHuman(this.props.count)}
          </div>
        </a>
      </div>
    )
  }

  renderHeartState(classes) {
    if (!this.props.hearted) {
      return <div className={classes}>
        <i className="fa fa-heart-o" />
      </div>
    }
    return <div className={classes + ' hearted'}>
      <i className="fa fa-heart" />
    </div>
  }

  numberToHuman(number) {
    const s = ['', 'k', 'M']
    var e = Math.floor(Math.log(number) / Math.log(1000))
    return (number / Math.pow(1000, e)).toFixed(0) + s[e]
  }
}

Heart.propTypes = {
  count: React.PropTypes.number,
  hearted: React.PropTypes.bool,
  onClick: React.PropTypes.func,
  layout: React.PropTypes.string,
}
