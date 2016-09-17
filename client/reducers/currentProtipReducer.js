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
  [PROTIP_MUTE_SUCCESS]: item => ({ item }),
  [PROTIP_MUTE_FAILURE]: item => ({ item }),
  [PROTIP_SUBSCRIBE_SUCCESS]: item => ({ item }),
  [PROTIP_SUBSCRIBE_FAILURE]: item => ({ item }),
})
