export default () => next => action => {
  console.log("Middleware", action, action.payload)
  if (action.payload && action.payload.status === 401) {
    window.location.replace('/signin?return_to=' + window.location)
  }
  // Pass the FSA to the next action.
  return next(action)
}
