export default function createReducer(initialState, handlers) {
  return (state, action) => {
    const handler = handlers[action.type]
    if (handler) {
      return {
        ...state,
        ...handler(action.payload, state, action, initialState),
      }
    }

    return state || initialState
  }
}
