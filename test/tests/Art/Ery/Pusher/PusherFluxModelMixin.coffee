{Promise, CommunicationStatus, eq, log, timeout, defineModule, BaseObject} = require 'art-foundation'
{FluxSubscriptionsMixin} = require 'art-flux'
{pipelines, session} = require 'art-ery'
{Config} = require 'art-ery-pusher'
{missing} = CommunicationStatus

subscriptionEstablishmentTimeout = 250

commonSetup = ->
  pipelines.simpleStore.reset()
  Config.onConnected()

class MySubscriber extends FluxSubscriptionsMixin BaseObject
  ;

queryKeyNoodleId = "123"

defineModule module, suite:
  "single record subscriber": ->
    @timeout 5000
    setup commonSetup

    test "update", ->
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

    test "delete", ->
      mySubscriber = new MySubscriber
      id = null

      new Promise (resolve) ->
        pipelines.simpleStore.create data: foo: "initial value"
        .then (response) ->
          {id} = response

          mySubscriber.subscribe
            modelName:  "simpleStore"
            key:        id
            callback:   ({status}) ->
              resolve() if status == missing

        .then -> timeout subscriptionEstablishmentTimeout
        .then ->
          pipelines.simpleStore.delete key: id

        # normally, the sender of an update will IGNORE the "changed" event from pusher
        # So, we must reset the session so we don't know we were the sender.
        .then -> session.reset()

      .then -> mySubscriber.unsubscribeAll()

  "query record subscriber": ->
    @timeout 5000
    setup commonSetup

    test "create", ->
      mySubscriber = new MySubscriber

      pipelines.simpleStore.reset
        data: 1: foo: "initial value", noodleId: queryKeyNoodleId
      .then ->
        new Promise (resolve) ->

          mySubscriber.subscribe
            modelName:  "pusherTestsByNoodleId"
            key:        queryKeyNoodleId
            callback:   ({data}) ->
              log {data}
              if data && eq ["initial value", "second value"], (r.foo for r in data)
                resolve()

          timeout subscriptionEstablishmentTimeout
          .then ->
            pipelines.simpleStore.create data: foo: "unrelated value", noodleId: queryKeyNoodleId + "different"

          .then ->
            pipelines.simpleStore.create data: foo: "second value", noodleId: queryKeyNoodleId

          # normally, the sender of an update will IGNORE the "changed" event from pusher
          # So, we must reset the session so we don't know we were the sender.
          .then -> session.reset()

      .then -> mySubscriber.unsubscribeAll()

    test "delete", ->
      mySubscriber = new MySubscriber
      pipelines.simpleStore.reset
        data:
          1: name: "alice",  noodleId: queryKeyNoodleId
          2: name: "bill",   noodleId: queryKeyNoodleId
          3: name: "cody",   noodleId: queryKeyNoodleId
          4: name: "dave",   noodleId: queryKeyNoodleId + "different"
      .then ->
        new Promise (resolve) ->
          mySubscriber.subscribe
            modelName:  "pusherTestsByNoodleId"
            key:        queryKeyNoodleId
            callback:   ({data}) ->
              if data && eq ["alice", "cody"], (r.name for r in data)
                resolve()

          timeout subscriptionEstablishmentTimeout
          .then -> pipelines.simpleStore.delete key: "2"

          # normally, the sender of an update will IGNORE the "changed" event from pusher
          # So, we must reset the session so we don't know we were the sender.
          .then -> session.reset()

      .then -> mySubscriber.unsubscribeAll()

    test "update", ->
      mySubscriber = new MySubscriber
      pipelines.simpleStore.reset
        data:
          1: name: "alice",  noodleId: queryKeyNoodleId
          2: name: "bill",   noodleId: queryKeyNoodleId
      .then ->
        new Promise (resolve) ->
          mySubscriber.subscribe
            modelName:  "pusherTestsByNoodleId"
            key:        queryKeyNoodleId
            callback:   ({data}) ->
              if data && eq ["alice", "bob"], (r.name for r in data)
                resolve()

          timeout subscriptionEstablishmentTimeout
          .then -> pipelines.simpleStore.update key: "2", data: name: "bob"

          # normally, the sender of an update will IGNORE the "changed" event from pusher
          # So, we must reset the session so we don't know we were the sender.
          .then -> session.reset()

      .then -> mySubscriber.unsubscribeAll()

  misc: ->
    @timeout 5000
    setup commonSetup

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
