// http://fontawesome.io/icons/
import React, { PropTypes as T } from 'react'
import classNames from 'classnames'

const Icon = ({ icon, extraClasses }) => (
  <i className={classNames('fa', `fa-${icon}`, extraClasses)} />
)

Icon.propTypes = {
  icon: T.string.isRequired,
  extraClasses: T.string,
}

export default Icon
