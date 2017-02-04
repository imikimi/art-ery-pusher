{defineModule} = require 'art-foundation'
PusherFluxModelMixin = require './PusherFluxModelMixin'
PusherFilter = require './PusherFilter'

defineModule module, -> (superClass) -> class PusherPipelineMixin extends superClass
  @abstractClass?()
  @fluxModelMixin PusherFluxModelMixin

  ###
  NOTE: This Filter will run very first after the handler
  since it is defined in the mixin - before the body of the
  actual class is evaluated.

  This is fine for now, but if we ever want to push actual data, we may
  need this to run after other filters which refine said data.
  ###
  @filter PusherFilter
