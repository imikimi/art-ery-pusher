{defineModule, randomString, formattedInspect, log} = require 'art-foundation'
{pipelines} = require 'art-ery'
{Config, config} = require 'art-ery-pusher'

subscribeTest = ({data, requestType, subscriptionPipeline, subscriptionKey}) ->
  subscriptionPipeline ||= "simpleStore"
  test "#{requestType} should trigger event", ->
    listener = channelSubscription = null

    pipelines.simpleStore.create()
    .then ({id}) ->
      subscriptionKey ||= id
      channel = Config.getPusherChannel subscriptionPipeline, subscriptionKey

      new Promise (resolve) ->
        log "starting subscription listener for #{channel}::#{config.pusherEventName}"
        channelSubscription = Config.pusherClient.subscribe channel
        .bind config.pusherEventName, listener = resolve

        pipelines.simpleStore[requestType] {key: id, data}

      .then (result) ->
        log "channel: #{channel}, event: #{config.pusherEventName}": {result}
        channelSubscription.unbind listener
        Config.pusherClient.unsubscribe channel

defineModule module, suite:
  "basic requests": ->
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

  "round trip tests": ->
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
