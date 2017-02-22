/* global fetch */
import React, { Component } from 'react'
import Icon from './Icon'
import TrackClick from './TrackClick'

const Sponsor = (sponsor) => (
  <div className="clearfix py1">
    <TrackClick
      category="Ads"
      action="Protip Sidebar - Sponsor"
      label={`${sponsor.title} - ${sponsor.id}`}>
      <a
        className="link no-hover"
        href={sponsor.click_url}
        rel="nofollow noopener noreferrer"
        target="_blank">
        <div className="col col-3 md-col-2">
          <img src={sponsor.image_url} className="mt-third" role="presentation" />
        </div>
        <div className="overflow-hidden pl2">
          <div className="blue bold">{sponsor.title}</div>
          <div className="font-sm black mt-third">
            {sponsor.text}
            {sponsor.pixel_urls.map(url =>
              <img
                key={url}
                src={url.replace('[timestamp]', Math.round(Date.now() / 10000) | 0)}
                style={{ display: 'none' }}
                width={1}
                height={1}
                role="presentation" />
            )}
          </div>
        </div>
      </a>
    </TrackClick>
  </div>
)


export default class Sponsors extends Component {
  render() {
    if (!this.state) { return null }
    const { sponsors } = this.state
    return (
      <div className="clearfix sm-ml3 mt3 p1">
        <h5 className="mt0 mb1">
          <Icon icon="hand-o-right" extraClasses="mr1" />
          Sponsors
        </h5>
        <hr className="mt1" />
        {sponsors.map(s => <Sponsor key={s.id} {...s} />)}
      </div>
    )
  }

  componentDidMount() {
    fetch('/sponsors.json').
      then(resp => resp.json()).
      then(json => this.setState(json))
  }
}
