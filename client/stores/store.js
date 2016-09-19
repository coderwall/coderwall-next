/* global window */
import { combineReducers, applyMiddleware, createStore, compose } from 'redux'
import promise from 'redux-promise'
import thunk from 'redux-thunk'
import { apiMiddleware } from 'redux-api-middleware'
import { reducer as form } from 'redux-form'
import apiAuthInjector from '../lib/apiAuthInjector'

import reducers from '../reducers'

export const STATE_HYDRATED = 'STATE_HYDRATED'

export default function configureStore(props) {
  const store = createStore(
    combineReducers({
      ...reducers,
      form,
    }),
    props,
    compose(
      applyMiddleware(
        thunk,
        promise,
        apiAuthInjector,
        apiMiddleware
      ),
      window.devToolsExtension ? window.devToolsExtension() : f => f
    )
  )

  store.dispatch({ type: STATE_HYDRATED, payload: store.getState() })

  return store
}
