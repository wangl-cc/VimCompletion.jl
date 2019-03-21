module VimCompletion

export vimapi

include("complete.jl")

function vimfindstart(io, line::AbstractString, pos::Int)
    println(findstart(io, line, pos))
end

function vimfindstart(io,line::AbstractString, pos::AbstractString)
    vimfindstart(io, line, Meta.parse(pos))
end

function vimcompletion(io, base::AbstractString, pos::Int, context_module=Main)
    completionlist, should_complete = getcompletion(base, pos, context_module)
    if should_complete
        for i in completionlist
            print(io, i .* ',')
        end
    else
        print(io, base)
    end
    nothing
end

function vimcompletion(io, base::AbstractString, pos::AbstractString, context_module=Main)
    vimcompletion(io, base, Meta.parse(pos), context_module)
end

function vimapi(io, cmdargs)
    opt = cmdargs[1]
    args = cmdargs[2:end]
    if opt == "-f"
        vimfindstart(io, args...)
    elseif opt == "-c"
        vimcompletion(io, args...)
    end
    nothing
end

end # module
