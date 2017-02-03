{defineModule} = require 'art-foundation'
{pipelines} = require 'art-ery'

defineModule module, suite: ->
  test "create", ->
    pipelines.pusherTestPipeline.create data: foo: "bar"
