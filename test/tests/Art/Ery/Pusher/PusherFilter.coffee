{defineModule, randomString, formattedInspect, log} = require 'art-foundation'
{pipelines} = require 'art-ery'
{Config, config} = require 'art-ery-pusher'

subscribeTest = ({data, key, requestType, pipeline, subscriptionKey}) ->
  pipeline ||= "pusherTestPipeline"
  subscriptionKey ||= key
  channel = Config.getPusherChannel pipeline, subscriptionKey
  test "#{requestType} should trigger event on #{channel}", ->
    listener = channelSubscription = null

    new Promise (resolve) ->
      log "starting subscription listener for #{channel}::#{config.pusherEventName}"
      channelSubscription = Config.pusherClient.subscribe channel
      .bind config.pusherEventName, listener = resolve

      pipelines.pusherTestPipeline[requestType] {key, data}

    .then (result) ->
      log "channel: #{channel}, event: #{config.pusherEventName}": {result}
      channelSubscription.unbind listener
      Config.pusherClient.unsubscribe channel

defineModule module, suite:
  "basic requests": ->
    test "create should only notifiy related queries", ->
      pipelines.pusherTestPipeline.create data: noodleId: "noodle1"

    test "update should notifiy related queries and the updated record", ->
      pipelines.pusherTestPipeline.update data: noodleId: "noodle2", id: randomString()

    test "delete should notifiy related queries and the deleted record", ->
      pipelines.pusherTestPipeline.delete key: randomString()

  "round trip tests": ->
    subscribeTest
      requestType: "update"
      key: key = "ust1"
      data: id: key

    subscribeTest
      requestType: "delete"
      key: key = "ust1"

    subscribeTest
      requestType: "update"
      key: key = "ust1"
      pipeline: "pusherTestsByNoodleId"
      data: id: key, noodleId: "123"
      subscriptionKey: "123"
