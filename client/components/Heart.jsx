import React, { PropTypes as T } from 'react'
import Icon from './Icon'

const numberToHuman = (number) => {
  if (number > 0) {
    const s = ['', 'K', 'M']
    const e = Math.floor(Math.log(number) / Math.log(1000))
    return (number / Math.pow(1000, e)).toFixed(0) + s[e]
  }

  return 0
}

const renderCount = (cnt) => (
  <div className="font-tiny">
    {numberToHuman(cnt)}
  </div>
)

const renderLabel = (hearted) => (
  <span className="black ml1">
    {hearted ? 'Recommended' : 'Recommend'}
  </span>
)

const Heart = ({ hearted, showLabel, showCount, count, onClick }) => {
  const icon = hearted ? 'heart' : 'heart-o'
  return (
    <div className="inline pointer center purple" onClick={onClick}>

      <span className="fixed-space-4">
        <Icon icon={icon} extraClasses="purple h5" />
      </span>

      {showLabel && renderLabel(hearted)}
      {showCount && renderCount(count)}
    </div>
  )
}

Heart.propTypes = {
  count: T.number,
  hearted: T.bool,
  onClick: T.func,
  showLabel: T.bool,
  showCount: T.bool,
}

export default Heart
