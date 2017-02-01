{
  each, formattedInspect, deepMerge, merge, defineModule, log, Validator, m, isFunction, objectHasKeys
} = require 'art-foundation'

{Filter} = require 'art-ery'

{getPusherChannel, pusherEventName} = require './Common'

sendChanged = (pipeline, key) ->
  channel = getPusherChannel pipeline, key
  pusher.send channel, pusherEventName, data = {}

defineModule module, class PusherFilter extends Filter
  @location "server"
  @after all: (response) ->
    switch response.type
      when "create", "update", "delete"
      else return response

    Promise.then ->
      {type, key, data, pipelineName, request, pipeline} = response
      data = merge request.data, data, key && pipeline.toKeyObject key

      promises = for queryPipeline in pipeline.queries
        sendChanged queryPipeline, data

      promises.push sendChanged pipeline, data

      promises

    .then -> response