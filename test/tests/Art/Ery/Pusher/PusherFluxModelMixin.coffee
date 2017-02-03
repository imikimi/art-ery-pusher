{log, defineModule, BaseObject} = require 'art-foundation'
{FluxSubscriptionsMixin} = require 'art-flux'
{pipelines} = require 'art-ery'

defineModule module, suite: ->
  class MySubscriber extends FluxSubscriptionsMixin BaseObject
    ;

  test "foo", ->
    mySubscriber = new MySubscriber
    myTestKey = "123"

    mySubscriber.subscribe
      modelName:  "pusherTestPipeline"
      key:        myTestKey
      callback:   (fluxRecord) -> log {fluxRecord}

    mySubscriber.unsubscribe "pusherTestPipeline"
