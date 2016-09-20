import createReducer from '../lib/createReducer'

import {
  PROTIP_MUTE_REQUEST,
  PROTIP_MUTE_SUCCESS,
  PROTIP_MUTE_FAILURE,
  PROTIP_SUBSCRIBE_REQUEST,
  PROTIP_SUBSCRIBE_SUCCESS,
  PROTIP_SUBSCRIBE_FAILURE,
} from '../actions/protipActions'

const add = (array, item) => [...array, item]
const remove = (array, item) => array.filter(i => i !== item)

export default createReducer({
  item: null,
}, {
  [PROTIP_SUBSCRIBE_REQUEST]: ({ payload: { userId } }, state) => ({
    item: { ...state.item, subscribers: add(state.item.subscribers, userId) },
  }),
  [PROTIP_MUTE_REQUEST]: ({ payload: { userId } }, state) => ({
    item: { ...state.item, subscribers: remove(state.item.subscribers, userId) },
  }),

  [PROTIP_SUBSCRIBE_SUCCESS]: ({ payload }) => ({ item: payload }),
  [PROTIP_SUBSCRIBE_FAILURE]: ({ payload }) => ({ item: payload }),
  [PROTIP_MUTE_SUCCESS]: ({ payload }) => ({ item: payload }),
  [PROTIP_MUTE_FAILURE]: ({ payload }) => ({ item: payload }),
})
