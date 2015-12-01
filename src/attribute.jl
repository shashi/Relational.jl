export Attr, Literal, Field
abstract Attr{T}
eltype{T}(::Attr{T}) = T

immutable Literal{T} <: Attr{T}
    value::T
end
name(l::Literal) = symbol(string(l.value))

convert{T<:Number}(::Type{Attr}, x::T) = Literal(x)

immutable Field{T} <: Attr{T}
    name::Symbol
end
Field(T, name) = Field{T}(name)
name(f::Field) = f.name

immutable As{T} <: Attr{T}
    name::Symbol
    field::Attr{T}
end
name(x::As) = x.name

immutable BinOp{op, L, R, T} <: Attr{T}
    l::Attr{L}
    r::Attr{R}
end
name{op}(f::BinOp{op}) = symbol(string(name(f.l), op, name(f.r)))

for op in [:(==), :(>=), :(<=), :(!=), :($), :(&), :(|)]
    quote
        function Base.$op{L, R}(l::Attr{L}, r::Attr{R})
            BinOp{$(Meta.quot(op)),L,R,Bool}(l,r)
        end
        function Base.$op{L, R}(l::Attr{L}, r::R)
            BinOp{$(Meta.quot(op)),L,R,Bool}(l,Literal(r))
        end
        function Base.$op{L, R}(l::L, r::Attr{R})
            BinOp{$(Meta.quot(op)),L,R,Bool}(Literal(l),r)
        end
    end |> eval
end

for op in [:+, :-, :*]
    @eval begin
        function Base.$op{L, R}(l::Attr{L}, r::Attr{R})
            BinOp{$(Meta.quot(op)),L,R,promote_type(L,R)}(l,r)
        end
        function Base.$op{L, R}(l::Attr{L}, r::R)
            BinOp{$(Meta.quot(op)),L,R,promote_type(L,R)}(l,Literal(r))
        end
        function Base.$op{L, R}(l::L, r::Attr{R})
            BinOp{$(Meta.quot(op)),L,R,promote_type(L,R)}(Literal(l),r)
        end
    end
end

abstract Aggregator <: Attr

immutable Count <: Aggregator end
name(::Count) = symbol("count()")

immutable Avg <: Aggregator
    attr::Attr
end
name(a::Avg) = symbol("avg($(name(a.attr)))")

immutable Sum <: Aggregator
    attr::Attr
end
name(s::Sum) = symbol("sum($(name(s.attr)))")

immutable ReduceAgg <: Aggregator
    f::Function
    attr::Attr
end
