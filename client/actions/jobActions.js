/* global window */
import { CALL_API } from 'redux-api-middleware'

export const JOB_POST_REQUEST = 'JOB_POST_REQUEST'
export const JOB_POST_SUCCESS = 'JOB_POST_SUCCESS'
export const JOB_POST_FAILURE = 'JOB_POST_FAILURE'

export function createPost(stripeToken, job) {
  return {
    [CALL_API]: {
      endpoint: `/jobs`,
      method: 'POST',
      body: JSON.stringify({ stripeToken, job }),
      types: [
        JOB_POST_REQUEST,
        JOB_POST_SUCCESS,
        JOB_POST_FAILURE,
      ],
    },
  }
}
