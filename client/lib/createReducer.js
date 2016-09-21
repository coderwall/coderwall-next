export default function createReducer(initialState, handlers) {
  if (Object.keys(handlers).filter(k => !k || k.length === 0 || k === 'undefined').length > 0) {
    throw new Error("Tried to create reducer with empty keys")
  }

  return (state, action) => {
    const handler = handlers[action.type]
    if (handler) {
      return {
        ...state,
        ...handler(action, state, initialState),
      }
    }

    return state || initialState
  }
}
