using REPL.REPLCompletions
using JSON

const home = homedir()

function getcompletion(base::AbstractString, pos::Int, context_module=Main)
    if pos == 0
        return [], false
    end
    if pos >= 2 && base[1:2] in ("\"~", "`~")
        nbase = base[1] * home * base[3:end]
        base = nbase
        pos += (length(home)-1)
    end
    ret, range, should_complete = completions(base, pos, context_module)
    completionlist = unique(completion_text.(ret))
    maxsymbolpos = 0
    for i in ('`', '"', '/', '.', ' ')
        symbolpos = findprev(isequal(i), base, pos)
        if !isnothing(symbolpos)
            if symbolpos > maxsymbolpos
                if i == '.'
                    if maxsymbolpos == 0
                        maxsymbolpos = symbolpos
                    end
                else
                    maxsymbolpos = symbolpos
                end
            end
        end
    end
    if maxsymbolpos != 0
        completionlist =  base[1:maxsymbolpos] .* completionlist
    end
    return completionlist, should_complete
end

function evalstr(str::AbstractString, context_module=Main)
    result = nothing
    try
        result = context_module.eval(Meta.parse(str))
    catch error
        result = error
    end
    return result
end

function writecompletion(io, base::AbstractString, pos::Int, context_module=Main)
    completionlist, should_complete = getcompletion(base, pos, context_module)
    if should_complete
        JSON.Writer.print(io, completionlist)
    else
        JSON.Writer.print(io, [base])
    end
    nothing
end

function writecompletion(io, base::AbstractString, pos::AbstractString, context_module=Main)
    writecompletion(io, base, Meta.parse(pos), context_module)
end

function writeeval(io, str::AbstractString, context_module=Main)
    result = evalstr(str, context_module)
    if isnothing(result)
        JSON.Writer.print(io, ["Nothing"])
    elseif isa(result, Function)
        JSON.Writer.print(io, ["Function"])
    else
        JSON.Writer.print(io, [typeof(result), result])
    end
end
