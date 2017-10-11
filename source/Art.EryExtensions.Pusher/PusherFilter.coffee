{
  log
  each, formattedInspect, deepMerge, merge, defineModule, log, Validator, m, isFunction, objectHasKeys
  Promise
  isString
  cryptoRandomString
} = require 'art-foundation'

{Filter} = require 'art-ery'

{config} = Config = require './Config'

sendChanged = (pipeline, key, payload) ->
  {pusherEventName} = config

  channel = Config.getPusherChannel pipeline, key
  log sendChanged: {channel, payload} if config.verbose
  Config.pusherServer?.trigger channel, pusherEventName, payload || {}

defineModule module, class PusherFilter extends Filter
  @location "server"
  @after all: (response) ->
    switch response.type
      when "create", "update", "delete"
      else return response

    (if isString response.session.artEryPusherSession
      Promise.resolve response
    else
      response.withMergedSession artEryPusherSession: cryptoRandomString 12 # should produce > 10^21 unique values
    ).then (response) ->

      Promise.then ->
        {type, key, data, pipelineName, request, pipeline, session} = response
        data = merge request.data, data, key && pipeline.toKeyObject key

        payload = {
          type
          sender:   session.artEryPusherSession
          key:      key || pipeline.toKeyString data
        }
        payload.updatedAt = data.updatedAt if data.updatedAt

        promises = for queryName, pipelineQuery of pipeline.queries
          if key = pipelineQuery.toKeyString data
            sendChanged queryName, key, payload

        # record updated notification - no need to send on 'create' because no-one will be listening.
        unless type == "create"
          promises.push sendChanged pipeline, data, payload

        promises

      .then -> response
