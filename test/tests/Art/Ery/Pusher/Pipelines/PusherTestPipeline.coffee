{defineModule, randomString, merge} = require 'art-foundation'
{PusherPipelineMixin} = require 'art-ery-pusher'
{Pipeline, KeyFieldsMixin} = require 'art-ery'

defineModule module, class PusherTestPipeline extends PusherPipelineMixin KeyFieldsMixin Pipeline
  @remoteServer "http://localhost:8085"

  @query
    pusherTestsByNoodleId:
      query: (request) -> [] # empty result set
      toKeyString: ({noodleId}) -> noodleId

  @handlers
    # get:    (request) ->

    create: (request) ->
      merge request.data,
        id: randomString()

    update: (request) -> request.data

    delete: (request) -> request.success()
