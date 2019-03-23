using Sockets
import Base.run
using JSON

struct CompletionServer
    s::Base.LibuvServer
    debugmod::Bool
end

function CompletionServer(host::IPAddr, port::Integer, debugmod::Bool)
    CompletionServer(listen(host, port), debugmod)
end

function CompletionServer(port::Integer, debugmod::Bool)
    CompletionServer(listen(port), debugmod)
end

function run(server::CompletionServer)
    stream = accept(server.s)
    while isopen(stream)
        cmd = JSON.Parser.parse(stream)
        if server.debugmod
            println(cmd)
        end
        vimapi(stream, cmd)
    end
end

function serverstart(host, port, debugmod::Bool=false)
    if host == "localhost"
        run(CompletionServer(port, debugmod))
    else
        host = IPv4(host)
        run(CompletionServer(host, port, debugmod))
    end
end
