module VimCompletion

include("complete.jl")

function vimfindstart(line::AbstractString, pos::Int)
    println(findstart(line, pos))
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

function vimapi(cmdargs)
    opt = cmdargs[1]
    args = cmdargs[2:end]
    if opt == "-f"
        findstart(args...)
    elseif opt == "-c"
        vimcompletion(args...)
    end
    nothing
end

end # module
