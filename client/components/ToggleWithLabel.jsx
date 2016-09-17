import React, { PropTypes as T } from 'react'
import Icon from './Icon'

const ToggleWithLabel = (props) => {
  const { icon, label } = props.on ? {
    icon: props.iconOn,
    label: props.labelOn,
  } : {
    icon: props.iconOff,
    label: props.labelOff,
  }
  return (
    <div className="inline pointer" onClick={props.onClick}>
      <span className="fixed-space-4"><Icon icon={icon} /></span>
      {label}
    </div>
  )
}

ToggleWithLabel.propTypes = {
  iconOff: T.string.isRequired,
  iconOn: T.string.isRequired,
  labelOff: T.string.isRequired,
  labelOn: T.string.isRequired,
  on: T.bool.isRequired,
  onClick: T.func.isRequired,
}

export default ToggleWithLabel
