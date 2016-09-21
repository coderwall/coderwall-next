import React, { PropTypes as T } from 'react'

const ChatComment = props => (
  <div className="comment py1">
    <div className="left mt1 mr2 avatar small" style={{ backgroundColor: '#913894' }} />
    <div className="overflow-hidden py0 mt0">
      <div className="clearfix">
        <div className="author">
          <a className="bold black no-hover" href={props.authorUrl}>
            {props.authorUsername}
          </a>
        </div>
        <div
          className="content small" dangerouslySetInnerHTML={{ __html: props.markup }} />
      </div>
    </div>
  </div>
)

ChatComment.propTypes = {
  authorUrl: T.string.isRequired,
  authorUsername: T.string.isRequired,
  markup: T.string.isRequired,
}

export default ChatComment
