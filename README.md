# ArtEryPusher

An ArtEry Filter for using Pusher.com to trigger updates in all clients when after all creates and updates.

### Usage

ArtEryPusher needs to be 'required' differently depending on if this is the Client or the Server. This is an unfortunate side-effect of how Pusher bundles their code.

#### Client

```coffeescript
{PusherFilter, PusherFluxModelMixin} = require 'art-ery-pusher/Client'
{FluxModel} = require 'art-flux'
{Pipeline} = require 'art-ery'

class MyPusherFluxModel extends PusherFluxModelMixin FluxModel

class MyPusherPipeline extends Pipeline
  @filter PusherFilter
```

#### Server

```coffeescript
{PusherFilter} = require 'art-ery-pusher/Server'

class MyPusherPipeline extends Pipeline
  @filter PusherFilter
```