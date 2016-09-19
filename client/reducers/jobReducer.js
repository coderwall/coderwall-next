import createReducer from '../lib/createReducer'

import {
  JOB_POST_SUCCESS,
  JOB_POST_FAILURE,
} from '../actions/jobActions'


export default createReducer({
  error: null,
  item: null,
}, {
  [JOB_POST_SUCCESS]: ({ payload }) => ({ item: payload.job }),
  [JOB_POST_FAILURE]: ({ error }) => ({ error }),
})
