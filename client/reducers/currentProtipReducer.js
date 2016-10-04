import createReducer from '../lib/createReducer'

import {
  PROTIP_MUTE_REQUEST,
  PROTIP_MUTE_FAILURE,
  PROTIP_SUBSCRIBE_REQUEST,
  PROTIP_SUBSCRIBE_FAILURE,
} from '../actions/protipActions'

import {
  HEART_REQUEST,
} from '../actions/heartActions'

const incHeart = (tip, heartableId) => {
  // console.log({tip, heartableId})
  if (!tip || tip.heartableId !== heartableId) { return tip }

  return {
    ...tip,
    hearts: tip.hearts + 1,
    subscribed: true,
  }
}

const setSubscribed = (subscribed) => (_, state) => ({
  item: { ...state.item, subscribed },
})

export default createReducer({
  item: null,
}, {
  [PROTIP_SUBSCRIBE_REQUEST]: setSubscribed(true),
  [PROTIP_SUBSCRIBE_FAILURE]: setSubscribed(false),
  [PROTIP_MUTE_REQUEST]: setSubscribed(false),
  [PROTIP_MUTE_FAILURE]: setSubscribed(true),

  [HEART_REQUEST]: ({ payload: { heartableId } }, state) => ({
    item: incHeart(state.item, heartableId),
  }),
})
