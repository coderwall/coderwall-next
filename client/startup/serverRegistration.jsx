// TODO server rendering

// import { Provider } from 'react-redux'
// import React from 'react'
// import ReactOnRails from 'react-on-rails'
// import store from '../stores/store'
// import HeartButton from '../components/HeartButton'
//
// ReactOnRails.registerStore({ store })
//
// function withStore(c) {
//   return props => React.createElement(
//     Provider,
//     { store: ReactOnRails.getStore('store') },
//     React.createElement(c, props)
//   )
// }
//
// function registerContainers(containers) {
//   const containersWithStore = Object.keys(containers).
//     reduce((h, k) => ({ ...h, [k]: withStore(containers[k]) }), {})
//   ReactOnRails.register(containersWithStore)
// }
//
// // Only container compoments need to be registered here
// // container components are rendered directly in view html
// // components that are children of containers don't need to be registered
// registerContainers({
//   HeartButton,
// })
