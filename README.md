# ArtEryPusher

An ArtEry Filter for using Pusher.com to trigger updates in all clients when after all creates and updates.

### Usage

ArtEryPusher needs to be 'required' differently depending on if this is the Client or the Server. This is an unfortunate side-effect of how Pusher bundles their code.

#### Init

Because Pusher has different libraries for client and server, you need to require a different file depending on your context. This can be done right a the beginning of either your client or server code. It just loads the correct pusher library.

Client:
```coffeescript
require 'art-ery-pusher/Client'
```

Server:
```coffeescript
require 'art-ery-pusher/Server'
```

#### Config

ArtEryPusher uses the standard ArtSuite config system. There are many places you can set your config:

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

Recommendations:
* Production: Use shell environment variables set on the server. Never check in production keys into your source control.
* Development: Use whichever one is convenient.

#### Client & Server

This code will work both on the client and the server

```coffeescript
{PusherPipelineMixin} = require 'art-ery-pusher'
{Pipeline} = require 'art-ery'

class MyPusherPipeline extends PusherPipelineMixin Pipeline
  ...
```

#### Client without Flux

You can also use this w/o flux, theoretically.

```coffeescript
{PusherFluxModelMixin} = require 'art-ery-pusher/Client'
{FluxModel} = require 'art-flux'

class MyPusherFluxModel extends PusherFluxModelMixin FluxModel
```
