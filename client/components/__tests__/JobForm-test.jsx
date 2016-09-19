/* global test, expect */
import React from 'react'
import renderer from 'react-test-renderer'
import { combineReducers, createStore } from 'redux'
import { Provider } from 'react-redux'
import { reduxForm, reducer as form } from 'redux-form'

import { JobForm } from '../JobForm'

test('renders correctly', () => {
  const store = createStore(
    combineReducers({ form }),
    { form: {} }
  )

  const Decorated = reduxForm({ form: 'testForm' })(JobForm)
  const tree = renderer.create(
    <Provider store={store}>
      <Decorated />
    </Provider>
  )
  expect(tree).toMatchSnapshot()
})
