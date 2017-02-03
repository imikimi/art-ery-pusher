{log, timeout, defineModule, BaseObject} = require 'art-foundation'
{FluxSubscriptionsMixin} = require 'art-flux'
{pipelines} = require 'art-ery'

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

    .then ->
      mySubscriber.unsubscribe "simpleStore"
