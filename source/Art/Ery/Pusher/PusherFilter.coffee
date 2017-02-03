{
  log
  each, formattedInspect, deepMerge, merge, defineModule, log, Validator, m, isFunction, objectHasKeys
  Promise
} = require 'art-foundation'

{Filter} = require 'art-ery'

{config} = Config = require './Config'

sendChanged = (pipeline, key, payload) ->
  {pusherEventName} = config

  channel = Config.getPusherChannel pipeline, key
  Config.pusherServer.trigger? channel, pusherEventName, payload || {}

defineModule module, class PusherFilter extends Filter
  @location "server"
  @after all: (response) ->
    switch response.type
      when "create", "update", "delete"
      else return response

    Promise.then ->
      {type, key, data, pipelineName, request, pipeline} = response
      data = merge request.data, data, key && pipeline.toKeyObject key

      payload = {type}

      promises = for queryName, {toKeyString} of pipeline.queries
        if key = toKeyString data
          sendChanged queryName, key, payload

      # record updated notification - no need to send on 'create' because no-one will be listening.
      unless type == "create"
        promises.push sendChanged pipeline, data, payload

      promises

    .then -> response