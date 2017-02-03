{log, timeout, defineModule, BaseObject} = require 'art-foundation'
{FluxSubscriptionsMixin} = require 'art-flux'
{pipelines, session} = require 'art-ery'

defineModule module, suite: ->
  class MySubscriber extends FluxSubscriptionsMixin BaseObject
    ;

  test "full test", ->
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
            resolve() if data.foo == "second value"

      .then ->
        pipelines.simpleStore.update log data: {id, foo: "second value"}

      # normally, the sender of an update will IGNORE the "changed" event from pusher
      # So, we must reset the session so we don't know we were the sender.
      .then -> session.reset()

    .then ->
      mySubscriber.unsubscribe "simpleStore"

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
