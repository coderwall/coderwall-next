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

const renderLabels = (hearted, [off, on]) => (
  <span className="black ml1">
    {hearted ? on : off}
  </span>
)

const Heart = ({ hearted, labels, count, onClick }) => {
  const icon = hearted ? 'heart' : 'heart-o'
  return (
    <div className="inline pointer center purple" onClick={onClick}>

      <span className="fixed-space-4">
        <Icon icon={icon} extraClasses="purple h5" />
      </span>

      {labels ? renderLabels(hearted, labels) : renderCount(count)}
    </div>
  )
}

Heart.propTypes = {
  count: T.number,
  hearted: T.bool,
  onClick: T.func,
  labels: T.arrayOf(T.string),
}

export default Heart
