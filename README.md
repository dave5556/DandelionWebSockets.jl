# DandelionWebSockets
DandelionWebSockets is a client side WebSocket package.

## Usage
Create a subtype of `WebSocketHandler`, with callbacks for WebSocket events. Create a `WSClient` and
connect to a WebSocket server.

```
type MyHandler <: WebSocketHandler
    client::WSClient
end

# These are called when you get a text or binary frame, respectively.
on_text(handler::MyHandler, text::UTF8String) = ...
on_binary(handler::MyHandler, data::Vector{UInt8}) = ...

# These are called when the state of the WebSocket changes.
state_connecting(handler::MyHandler) = ...
state_open(handler::MyHandler)       = ...
state_closing(handler::MyHandler)    = ...
state_closed(handler::MyHandler)     = ...
```

The following functions are available on `WSClient`, to send frames to the server.

```
send_text(c::WSClient, s::UTF8String)
send_binary(c::WSClient, data::Vector{UInt8})

# Close the WebSocket.
stop(c::WSClient)
```

To connect to a WebSocket server, call
`wsconnect(client::WSClient, uri::URI, handler::WebSocketHandler)`.

## Releases and Julia
If you use Julia 0.6, use master for the time being. I intend to register this
package with a proper version, soon. The package will not remain compatible with
Julia prior to 0.6.

## Needs work

- Implement regular pings, to ensure the connection is up.
- Wait for Requests.jl next release.
  This package needs a HTTP Upgrade feature of Requests.jl, which is only present in master, not in
  the release 0.3.7.
- Ability to send multi-frame messages.

## License
DandelionWebSockets is licensed under the MIT license.
