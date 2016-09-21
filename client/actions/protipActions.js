import { CALL_API } from 'redux-api-middleware'

export const PROTIP_MUTE_REQUEST = 'PROTIP_MUTE_REQUEST'
export const PROTIP_MUTE_SUCCESS = 'PROTIP_MUTE_SUCCESS'
export const PROTIP_MUTE_FAILURE = 'PROTIP_MUTE_FAILURE'
export const PROTIP_SUBSCRIBE_REQUEST = 'PROTIP_SUBSCRIBE_REQUEST'
export const PROTIP_SUBSCRIBE_SUCCESS = 'PROTIP_SUBSCRIBE_SUCCESS'
export const PROTIP_SUBSCRIBE_FAILURE = 'PROTIP_SUBSCRIBE_FAILURE'

export function mute(protipId, userId) {
  return {
    [CALL_API]: {
      endpoint: `/p/${protipId}/subscribers`,
      method: 'DELETE',
      types: [
        { type: PROTIP_MUTE_REQUEST, payload: { protipId, userId } },
        PROTIP_MUTE_SUCCESS,
        PROTIP_MUTE_FAILURE,
      ],
    },
  }
}

export function subscribe(protipId, userId) {
  return {
    [CALL_API]: {
      endpoint: `/p/${protipId}/subscribers`,
      method: 'POST',
      types: [
        { type: PROTIP_SUBSCRIBE_REQUEST, payload: { protipId, userId } },
        PROTIP_SUBSCRIBE_SUCCESS,
        PROTIP_SUBSCRIBE_FAILURE,
      ],
    },
  }
}
