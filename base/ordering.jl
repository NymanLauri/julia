# This file is a part of Julia. License is MIT: https://julialang.org/license

module Order


import ..@__MODULE__, ..parentmodule
const Base = parentmodule(@__MODULE__)
import .Base:
    AbstractVector, @propagate_inbounds, isless, identity, getindex,
    +, -, !, &, <, |

## notions of element ordering ##

export # not exported by Base
    Ordering, Forward, Reverse, Backward,
    By, Less, Perm,
    ReverseOrdering, ForwardOrdering,
    DirectOrdering

abstract type Ordering end

struct Less{T<:Function} <: Ordering
    is_less::T
end

struct By{T,O<:Ordering} <: Ordering
    by::T
    is_less::O
end

struct Reverse{O<:Ordering} <: Ordering
    is_less::O
end

struct Perm{O<:Ordering,V<:AbstractVector} <: Ordering
    order::O
    data::V
end

# Simplify some things
Reverse(ord::Reverse) = ord.is_less
By(by::typeof(identity), ord::Ordering) = ord


(o::Less)(a, b)    = o.is_less(a, b)
(o::By)(a, b)      = o.is_less(o.by(a), o.by(b))
(o::Reverse)(a, b) = o.is_less(b, a)

const Forward = Less(isless)
const ForwardOrdering = typeof(Forward)
const Backward = Reverse(Forward)
const BackwardOrdering = typeof(Backward)
const DirectOrdering = Union{ForwardOrdering,BackwardOrdering}

_ord(lt, by, order::ForwardOrdering) = By(by,Less(lt))
_ord(lt, by, order::BackwardOrdering) = Reverse(By(by,Less(lt)))

ord(lt, by, rev::Nothing, order::Ordering=Forward) = _ord(lt, by, order)

function ord(lt, by, rev::Bool, order::Ordering=Forward)
    o = _ord(lt, by, order)
    return rev ? Reverse(o) : o
end

end
