using REPL.REPLCompletions
using JSON

"""
    findstart(line::AbstractString,pos::Int)::Int

Find complete start position of given string by recognize some separators. Because "using " in REPLCompletions is flag of package, which will be different. 

# Arguments
- `line::AbstractString`: A string contain chars from current line.
- `pos::Int`: Current cursor's col number.

# Example
```jldoctest
julia> findstart("using ", 6)
0

julia> findstart("func(arg", 6)
5

julia> findstart("1+arg", 6)
2
```
"""
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
    tmpstart = findprev(isequal('\\'), line, pos-1)
    tmpstart = isnothing(tmpstart) ? 0 : tmpstart-1
    if tmpstart >= start
        start = tmpstart
    end
    return start
end

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
