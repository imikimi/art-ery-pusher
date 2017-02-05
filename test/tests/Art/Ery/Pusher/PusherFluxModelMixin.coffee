{Promise, eq, log, timeout, defineModule, BaseObject} = require 'art-foundation'
{FluxSubscriptionsMixin} = require 'art-flux'
{pipelines, session} = require 'art-ery'
{Config} = require 'art-ery-pusher'

subscriptionEstablishmentTimeout = 250

defineModule module, suite: ->
  @timeout 5000
  setup ->
    pipelines.simpleStore.reset()
    Config.onConnected()

  class MySubscriber extends FluxSubscriptionsMixin BaseObject
    ;

  test "single record subscriber full test", ->
    mySubscriber = new MySubscriber
    id = null

    new Promise (resolve) ->
      pipelines.simpleStore.create data: foo: "initial value"
      .then (response) ->
        {id} = response

        mySubscriber.subscribe
          modelName:  "simpleStore"
          key:        id
          callback:   ({data}) ->
            log mySubscriber: callback: {data}
            resolve() if data?.foo == "second value"

      .then -> timeout subscriptionEstablishmentTimeout
      .then ->
        pipelines.simpleStore.update data: {id, foo: "second value"}

      # normally, the sender of an update will IGNORE the "changed" event from pusher
      # So, we must reset the session so we don't know we were the sender.
      .then -> session.reset()

    .then -> mySubscriber.unsubscribeAll()

  test "query-results-subscriber record added", ->
    mySubscriber = new MySubscriber
    id = null

    queryKeyNoodleId = "123"

    new Promise (resolve) ->
      pipelines.simpleStore.create data: foo: "initial value", noodleId: queryKeyNoodleId
      .then ->
        mySubscriber.subscribe
          modelName:  "pusherTestsByNoodleId"
          key:        queryKeyNoodleId
          callback:   ({data}) ->
            if data && eq ["initial value", "second value"], (r.foo for r in data)
              resolve()

      .then -> timeout subscriptionEstablishmentTimeout
      .then ->
        pipelines.simpleStore.create data: foo: "unrelated value", noodleId: queryKeyNoodleId + "different"

      .then ->
        pipelines.simpleStore.create data: foo: "second value", noodleId: queryKeyNoodleId

      # normally, the sender of an update will IGNORE the "changed" event from pusher
      # So, we must reset the session so we don't know we were the sender.
      .then -> session.reset()

    .then -> mySubscriber.unsubscribeAll()

  test "query-results-subscriber record deleted", ->
    queryKeyNoodleId = "123"
    pipelines.simpleStore.reset
      data:
        1: foo: "alice",  noodleId: queryKeyNoodleId
        2: foo: "bill",   noodleId: queryKeyNoodleId
        3: foo: "cody",   noodleId: queryKeyNoodleId
        4: foo: "dave",   noodleId: queryKeyNoodleId + "different"
    .then ->
      mySubscriber = new MySubscriber
      id = null


      resolver = new Promise (resolve) ->
        mySubscriber.subscribe
          modelName:  "pusherTestsByNoodleId"
          key:        queryKeyNoodleId
          callback:   ({data}) ->
            log mySubscriber: callback: {data}
            if data && eq ["initial value", "second value"], (r.foo for r in data)
              resolve()

      timeout subscriptionEstablishmentTimeout
      .then ->
        log "send delete"
        pipelines.simpleStore.delete key: "2"

      # normally, the sender of an update will IGNORE the "changed" event from pusher
      # So, we must reset the session so we don't know we were the sender.
      .then -> session.reset()

      .then -> resolver

      .then -> mySubscriber.unsubscribeAll()

  test "sender ignores updates they caused", ->
    mySubscriber = new MySubscriber
    id = null

    new Promise (resolve) ->
      pipelines.simpleStore.create data: foo: "initial value"
      .then (response) ->
        {id} = response

        mySubscriber.subscribe
          modelName:  "simpleStore"
          key:        id
          callback:   ({data}) ->
            throw new Error "sender shouldn't get updated" if data.foo == "second value"

      .then ->
        pipelines.simpleStore.update log data: {id, foo: "second value"}

      # give the loop time to complete and fail, if it's going to
      .then ->
        timeout 500, resolve

    .then ->
      mySubscriber.unsubscribe "simpleStore"
