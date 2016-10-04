import createReducer from '../lib/createReducer'

import {
  HEART_REQUEST,
  HEART_FAILURE,
} from '../actions/heartActions'

export default createReducer({
  items: [],
}, {
  [HEART_REQUEST]: ({ payload: { heartableId } }, state) => ({
    items: [...state.items, heartableId],
  }),
  [HEART_FAILURE]: ({ payload: { heartableId } }, state) => ({
    items: state.items.filter(i => i !== heartableId),
  }),
})
