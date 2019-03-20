module VimCompletion

export vimapi

include("complete.jl")

function vimfindstart(line::AbstractString, pos::Int)
    println(findstart(line, pos))
end

function vimfindstart(line::AbstractString, pos::AbstractString)
    vimfindstart(line, Meta.parse(pos))
end

function vimcompletion(base::AbstractString, pos::Int, context_module=Main)
    completionlist, should_complete = getcompletion(base, pos, context_module)
    if should_complete
        print.( completionlist .* ',')
    else
        print(' ')
    end
    nothing
end

function vimcompletion(base::AbstractString, pos::AbstractString, context_module=Main)
    vimcompletion(base, Meta.parse(pos), context_module)
end

function vimapi(cmdargs)
    opt = cmdargs[1]
    args = cmdargs[2:end]
    if opt == "-f"
        vimfindstart(args...)
    elseif opt == "-c"
        vimcompletion(args...)
    end
    nothing
end

end # module
