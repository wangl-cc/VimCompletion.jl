using REPL.REPLCompletions
using JSON

function findstart(line::AbstractString, pos::Int)::Int
    if pos == 1
        return 0
    end
    findusing = findprev("using ", line, pos)
    if !isnothing(findusing)
        return findusing.start-1
    end
    start = 0
    for i in (' ', '(', ')', '[' , ']', '{' , '}', '=', '!', '+', '-', '+', '*', '&', '#', '$', '%', '^', '<', '>', '?', ',')
        tmpstart = findprev(isequal(i), line, pos-1)
        tmpstart = ifelse(isnothing(tmpstart), 0, tmpstart)
        if tmpstart >= start
            start = tmpstart
        end
    end
    return start
end

function getcompletion(base::AbstractString, pos::Int, context_module=Main)
    ret, range, should_complete = completions(base, pos, context_module)
    completionlist = unique(completion_text.(ret))
    if pos == 0
        return completionlist, should_complete
    end
    for i in ('.', '`', '"', '\\', '/', ' ')
        symbolpos = findprev(isequal(i), base, pos)
        if !isnothing(symbolpos)
            completionlist =  base[1:symbolpos] .* completionlist
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
