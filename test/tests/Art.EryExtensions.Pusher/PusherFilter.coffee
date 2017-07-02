{timeout, defineModule, randomString, formattedInspect, log} = require 'art-foundation'
{pipelines, session} = require 'art-ery'
{Config, config} = require 'art-ery-pusher'

subscriptionEstablishmentTimeout = 250

subscribeTest = ({data, requestType, subscriptionPipeline, subscriptionKey}) ->
  subscriptionPipeline ||= "simpleStore"
  test name = "#{subscriptionPipeline}.#{requestType} should trigger event", ->
    listener = channelSubscription = null

    pipelines.simpleStore.create()
    .then ({id}) ->
      subscriptionKey ||= id
      channel = Config.getPusherChannel subscriptionPipeline, subscriptionKey

      new Promise (resolve) ->
        channelSubscription = Config.pusherClient.subscribe channel
        .bind config.pusherEventName, listener = resolve

        timeout subscriptionEstablishmentTimeout
        .then -> pipelines.simpleStore[requestType] {key: id, data}

      .then (result) ->
        channelSubscription.unbind listener
        Config.pusherClient.unsubscribe channel

defineModule module, suite:
  "basic requests": ->
    setup ->
      Config.onConnected()

    test "create should only notifiy related queries", ->
      pipelines.simpleStore.create data: noodleId: "noodle1"

    test "update should notifiy related queries and the updated record", ->
      pipelines.simpleStore.create data: noodleId: "noodle1"
      .then ({id}) ->
        pipelines.simpleStore.update data: noodleId: "noodle2", id: id

    test "delete should notifiy related queries and the deleted record", ->
      pipelines.simpleStore.create data: noodleId: "noodle1"
      .then ({id}) ->
        pipelines.simpleStore.delete key: id

  "artEryPusherSession": ->
    setup ->
      session.reset()

    test "request generates session", ->
      assert.doesNotExist session.data.artEryPusherSession
      pipelines.simpleStore.create data: noodleId: "noodle1"
      .then ->
        assert.isString session.data.artEryPusherSession

    test "persists across requests", ->
      assert.doesNotExist session.data.artEryPusherSession
      artEryPusherSession = null
      pipelines.simpleStore.create data: noodleId: "noodle1"
      .then ->
        assert.isString session.data.artEryPusherSession
        {artEryPusherSession} = session.data
        pipelines.simpleStore.create data: noodleId: "noodle2"
      .then ->
        assert.eq artEryPusherSession, session.data.artEryPusherSession

  "round trip tests": ->
    setup ->
      Config.onConnected()

    subscribeTest
      requestType: "update"
      data: foo: "bar"

    subscribeTest
      requestType: "delete"

    subscribeTest
      requestType: "update"
      data: noodleId: "123"
      subscriptionPipeline: "pusherTestsByNoodleId"
      subscriptionKey: "123"
