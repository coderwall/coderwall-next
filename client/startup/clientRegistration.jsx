/* global document, $ */
// polyfills
import 'whatwg-fetch'
import 'pusher-js'

import { Provider } from 'react-redux'
import React from 'react'
import ReactOnRails from 'react-on-rails'

import store from '../stores/store'
import Chat from '../components/Chat'
import Heart from '../components/Heart'
import HeartButton from '../components/HeartButton'
import NewJob from '../components/NewJob'
import NewJobSubscription from '../components/NewJobSubscription'
import ProtipSubscribeButton from '../components/ProtipSubscribeButton'
import Sponsors from '../components/Sponsors'
import Video from '../components/Video'

ReactOnRails.setOptions({
  traceTurbolinks: TRACE_TURBOLINKS, // eslint-disable-line no-undef
})
ReactOnRails.registerStore({ store })

function withStore(c) {
  return props => React.createElement(
    Provider,
    { store: ReactOnRails.getStore('store') },
    React.createElement(c, props)
  )
}

function registerContainers(containers) {
  const containersWithStore = Object.keys(containers).
    reduce((h, k) => ({ ...h, [k]: withStore(containers[k]) }), {})
  ReactOnRails.register(containersWithStore)
}

// Only container compoments need to be registered here
// container components are rendered directly in view html
// components that are children of containers don't need to be registered
registerContainers({
  Chat,
  Heart,
  HeartButton,
  NewJob,
  NewJobSubscription,
  Sponsors,
  ProtipSubscribeButton,
  Video,
})
