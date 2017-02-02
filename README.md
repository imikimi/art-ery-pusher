# ArtEryPusher

An ArtEry Filter for using Pusher.com to trigger updates in all clients when after all creates and updates.

## Usage

The main thing you have to do is add the PusherPipelineMixin to every ArtEry.Pipeline you want to participate in Pusher notifications for data created, updated or deleted:

```coffeescript
{PusherPipelineMixin} = require 'art-ery-pusher'
{Pipeline} = require 'art-ery'

class MyPusherPipeline extends PusherPipelineMixin Pipeline
  ...
```

Typically you'll want to enable this for Pipelines which are database-backed. It adds the PusherFilter to the pipeline, and, if you are using ArtFlux in your client, it ensures the PusherFluxModelMixin is used when creating the FluxModels.

#### Init

Because Pusher has different libraries for client and server, you need to require a different file depending on your context. This can be done right at the beginning of either your client or server code. These only load the correct libraries. Initialization is done during configuration.

Client:
```coffeescript
require 'art-ery-pusher/Client'
```

Server:
```coffeescript
require 'art-ery-pusher/Server'
```

#### Config

ArtEryPusher uses the standard ArtSuite config system (currently in declared in Art.Foundation). The config path is "Art.Ery.Pusher." You can see all configurable options in: source/Art/Ery/Pusher/Config.coffee.

The ArtSuite config system allows you to set your config in whatever place is most convenient:

Shell environment variables:
```shell
# shell environment
> artConfig='{"Art.Ery.Pusher": {"apiId":"abc", "key": "def", "secret", "ghi"}}' npm start
```

Query-string:
```
/myPage?artConfig={"Art.Ery.Pusher": {"apiId":"abc", "key": "def", "secret", "ghi"}}
```

Config file:
```coffeescript
# Production.coffee
{defineModule, Config} = require 'art-foundation'

defineModule module, class Development extends Config
  Art: Ery: Pusher:
    apiId:  'abc'
    key:    'def'
    secret: 'ghi'
```

Javascript Global:
```coffeescript
# TODO: look up how to do this - or actually write some doc for Art.Foundation.Config!
```

Recommendations:
* Production: Use shell environment variables set on the server. Never check in production keys into your source control.
* Development: Use whichever one is convenient.
