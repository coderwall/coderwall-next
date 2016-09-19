import createReducer from '../lib/createReducer'

import {
  PROTIP_MUTE_SUCCESS,
  PROTIP_MUTE_FAILURE,
  PROTIP_SUBSCRIBE_SUCCESS,
  PROTIP_SUBSCRIBE_FAILURE,
} from '../actions/protipActions'

export default createReducer({
  item: null,
}, {
  [PROTIP_MUTE_SUCCESS]: ({ payload }) => ({ item: payload }),
  [PROTIP_MUTE_FAILURE]: ({ payload }) => ({ item: payload }),
  [PROTIP_SUBSCRIBE_SUCCESS]: ({ payload }) => ({ item: payload }),
  [PROTIP_SUBSCRIBE_FAILURE]: ({ payload }) => ({ item: payload }),
})
