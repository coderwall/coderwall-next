/* global document */
import { CALL_API } from 'redux-api-middleware'

export default () => next => action => {
  const callApi = action[CALL_API]

  // Check if this action is a redux-api-middleware action.
  if (callApi) {
    // Inject the CSRF token
    callApi.headers = {
      'X-CSRF-Token': document.getElementsByName('csrf-token')[0].content,
      'Content-Type': 'application/json',
      ...callApi.headers,
    }
    callApi.credentials = callApi.credentials || 'same-origin'
  }

  // Pass the FSA to the next action.
  return next(action)
}
