using REPL.REPLCompletions
using JSON


function findstart(line::AbstractString, pos::Int)::Int
    if line[pos] == ' '
        pos -= 1
    end
    start = findprev(isequal(' '), line, pos-1)
    return ifelse(isnothing(start), 0, start)
end

function getcompletion(base::AbstractString, pos::Int, context_module=Main)
    ret, range, should_complete = completions(base, pos, context_module)
    completionlist = unique(completion_text.(ret))
    if base[1:pos] == "using "
        completionlist = "using " .* completionlist
    elseif base[pos] == '('
        return completionlist, false
    else
        dotpos = findprev(isequal('.'), base, pos)
        if !isnothing(dotpos)
            completionlist =  base[1:dotpos] .* completionlist
        end
    end
    return completionlist, should_complete
end

function vimfindstart(io, line::AbstractString, pos::Int)
    JSON.Writer.print(io, findstart(line, pos))
end

function vimfindstart(io, line::AbstractString, pos::AbstractString)
    return vimfindstart(io, line, Meta.parse(pos))
end

function vimcompletion(io, base::AbstractString, pos::Int, context_module=Main)
    completionlist, should_complete = getcompletion(base, pos, context_module)
    if should_complete
        JSON.Writer.print(io, completionlist)
    else
        JSON.Writer.print(io, [base])
    end
    nothing
end

function vimcompletion(io, base::AbstractString, pos::AbstractString, context_module=Main)
    return vimcompletion(io, base, Meta.parse(pos), context_module)
end

function vimapi(io, cmd)
    opt = cmd[1]
    args = cmd[2:end]
    if opt == "-f"
        vimfindstart(io, args...)
    elseif opt == "-c"
        vimcompletion(io, args...)
    end
    nothing
end
