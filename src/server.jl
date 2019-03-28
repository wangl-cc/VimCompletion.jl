using Sockets
using JSON
import Base.run, Base.close

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

function close(server::CompletionServer)
    close(server.s)
end

function cmdparser(io, cmd)
    opt = cmd[1]
    args = cmd[2:end]
    if opt == "-c"
        writecompletion(io, args...)
    elseif opt == "-e"
        writeeval(io, args...)
    end
    nothing
end

function run(server::CompletionServer)
    stream = accept(server.s)
    while isopen(stream)
        try
            cmd = JSON.Parser.parse(stream)
            if server.debugmod
                println(cmd)
            end
            cmdparser(stream, cmd)
        catch error
            println(error)
            stream = accept(server.s)
        end
    end
    close(server)
end

function serverstart(host::AbstractString, port::Integer, debugmod::Bool=false)
    if host == "localhost"
        host = Sockets.localhost
    else
        host = IPv4(host)
    end
    server = CompletionServer(host, port, debugmod)
    run(server)
end
