/* global window */
export default () => next => action => {
  if (action.payload && action.payload.status === 401) {
    window.location = '/signin'
    return
  }

  next(action)
}
