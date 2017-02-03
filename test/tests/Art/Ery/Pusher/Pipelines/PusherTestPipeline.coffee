{defineModule, randomString} = require 'art-foundation'
{PusherPipelineMixin} = require 'art-ery-pusher'
{Pipeline} = require 'art-ery'

defineModule module, class PusherTestPipeline extends PusherPipelineMixin Pipeline

  @handlers
    # get:    (request) ->

    create: (request) ->
      merge request.data,
        id: randomString()

    update: (request) -> request.data

    delete: (request) -> request.success()
