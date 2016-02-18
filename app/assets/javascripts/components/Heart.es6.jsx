class Heart extends React.Component {
  render() {
    let classes = {
      root:  'heart no-hover',
      icon:  'highlight',
      count: 'diminish font-tiny',
      inline: ''
    }
    if (this.props.layout === 'inline') {
      classes = {
        root:  'heart no-hover font-x-lg',
        icon:  'highlight',
        count: 'ml1 diminish bold',
        inline: 'inline'
      }
    }
    if (this.props.layout === 'simple') {
      classes = {
        root:  'heart pointer',
        icon:  'highlight',
        count: 'ml1',
        inline: 'inline'
      }
    }
    return (
      <div className='inline'>
        <a className={classes.root} onClick={() => this.props.onClick()}>
          <center className={classes.inline}>
            {this.renderHeartState(classes.icon)}
          </center>
          {this.renderHeartCount(classes)}
        </a>
      </div>
    )
  }

  renderHeartCount(classes){
    if(this.props.layout != 'simple')
    {
      return <div className={classes.count}>
            <center className={classes.inline}>
              {this.numberToHuman(this.props.count)}
            </center>
          </div>
    }
  }

  renderHeartState(classes) {
    if (!this.props.hearted) {
      if(this.props.layout === 'simple')
      {
        return <span>Like?</span>
      }
      else
      {
        return <div className={classes + ' pointer'}>
          <i className={classes + ' pointer fa fa-heart-o'} />
        </div>
      }
    }

    return <div className={classes + ' hearted default-cursor'}>
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
