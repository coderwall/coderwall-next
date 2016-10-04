import createReducer from '../lib/createReducer'

import {
  HEART_REQUEST,
} from '../actions/heartActions'

const incHeart = (comments, id) => {
  if (!comments) { return null }
  const index = comments.findIndex(p => p.heartableId === id)
  if (index === -1) { return comments }
  const heartable = comments[index]
  return [
    ...comments.slice(0, index),
    { ...heartable, hearts: heartable.hearts + 1 },
    ...comments.slice(index + 1),
  ]
}

export default createReducer({
  items: null,
}, {
  [HEART_REQUEST]: ({ payload: { heartableId } }, state) => ({
    items: incHeart(state.items, heartableId),
  }),
})
