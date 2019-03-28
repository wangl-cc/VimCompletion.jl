using REPL.REPLCompletions
using JSON


"""
    getcompletion(base::AbstractString,pos::Int,context_module=Main)

By calling function completions in REPLCompletions get the completions of give str `base`.

# Arguments
- `base::AbstractString`: The string is to be complete.
- `pos::Int`: Current current col number.
- `context_module=Main`: Context module of completion.

# Example
```jldoctest
julia> getcompletion("using ", 6)
(["using Atom", "using BSON", "using Base", "using Base64", "using BenchmarkTools"
, "using CRC32c", "using CUDAdrv", "using CodecZlib", "using Conda", "using Core"
 …  "using Serialization", "using SharedArrays", "using Sockets", "using SparseArr
ays", "using Statistics", "using SuiteSparse", "using Test", "using UUIDs", "using
 Unicode", "using VimCompletion"], true)

julia> getcompletion("pri", 3)
(["primitive type", "print", "println", "printstyled"], true)

julia> getcompletion("Base.", 5)
(["Base.!", "Base.!=", "Base.!==", "Base.%", "Base.&", "Base.*", "Base.+", "Base.-
", "Base./", "Base.//"  …  "Base.≢", "Base.≤", "Base.≥", "Base.⊆", "Base.⊇", "Base
.⊈", "Base.⊉", "Base.⊊", "Base.⊋", "Base.⊻"], true)
```
"""
function getcompletion(base::AbstractString, pos::Int, context_module=Main)
    ret, range, should_complete = completions(base, pos, context_module)
    completionlist = unique(completion_text.(ret))
    if pos == 0
        return completionlist, should_complete
    end
    for i in ('.', '`', '"', '/', ' ')
        symbolpos = findprev(isequal(i), base, pos)
        if !isnothing(symbolpos)
            completionlist =  base[1:symbolpos] .* completionlist
        end
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
