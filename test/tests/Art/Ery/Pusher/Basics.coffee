{defineModule, randomString} = require 'art-foundation'
{pipelines} = require 'art-ery'

defineModule module, suite: ->
  test "create", ->
    pipelines.pusherTestPipeline.create data: noodleId: "noodle1"

  test "update", ->
    pipelines.pusherTestPipeline.update data: noodleId: "noodle2", id: randomString()
