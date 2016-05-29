import Requests: URI


type WSClient <: AbstractWSClient
    writer::AbstractWriterTaskProxy
    handler_proxy::AbstractHandlerTaskProxy
    logic_proxy::AbstractClientTaskProxy
    reader::Nullable{ServerReader}
    do_handshake::Function
    rng::AbstractRNG

    function WSClient(;
                      do_handshake=DandelionWebSockets.do_handshake,
                      rng::AbstractRNG=MersenneTwister(),
                      writer::AbstractWriterTaskProxy=WriterTaskProxy(),
                      handler_proxy::AbstractHandlerTaskProxy=HandlerTaskProxy(),
                      logic_proxy::AbstractClientTaskProxy=ClientLogicTaskProxy())
        new(writer, handler_proxy, logic_proxy, Nullable{ServerReader}(), do_handshake, rng)
    end
end

function connection_result_(client::WSClient, result::HandshakeResult, handler::WebSocketHandler)
    if !validate(result)
        state_closed(handler)
        return false
    end

    attach(client.writer, result.stream)
    start(client.writer)

    attach(client.handler_proxy, handler)
    start(client.handler_proxy)

    state_open(client.handler_proxy)

    logic = ClientLogic(STATE_OPEN, client.handler_proxy, client.writer, client.rng)
    attach(client.logic_proxy, logic)
    start(client.logic_proxy)

    client.reader = Nullable{ServerReader}(start_reader(result.stream, client.logic_proxy))
    true
end

function connection_result_(client::WSClient, result::HandshakeFailure, handler::WebSocketHandler)
    state_closed(handler)
    false
end


function wsconnect(client::WSClient, uri::URI, handler::WebSocketHandler)
    state_connecting(handler)
    new_uri = convert_ws_uri(uri)
    handshake_result = client.do_handshake(client.rng, new_uri)
    connection_result_(client, handshake_result, handler)
end
