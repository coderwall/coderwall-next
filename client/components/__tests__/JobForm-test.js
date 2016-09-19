/* global test, expect */
import React from 'react'
import renderer from 'react-test-renderer'

import JobForm from '../JobForm.jsx'

test('renders correctly', () => {
  const tree = renderer.create(<JobForm />)
  expect(tree).toMatchSnapshot()
})
