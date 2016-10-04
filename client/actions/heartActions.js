import { CALL_API } from 'redux-api-middleware'

export const HEART_REQUEST = 'HEART_REQUEST'
export const HEART_SUCCESS = 'HEART_SUCCESS'
export const HEART_FAILURE = 'HEART_FAILURE'

export function heart(endpoint, heartableId, userId) {
  return {
    [CALL_API]: {
      endpoint,
      method: 'POST',
      types: [
        { type: HEART_REQUEST, payload: { heartableId, userId } },
        HEART_SUCCESS,
        HEART_FAILURE,
      ],
    },
  }
}
