using REPL.REPLCompletions

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
        completionlist =  "using " .* completionlist
    else
        dotpos = findprev(isequal('.'), base, pos)
        if !isnothing(dotpos)
            completionlist =  base[1:dotpos] .* completionlist
        end
    end
    return completionlist, should_complete
end
