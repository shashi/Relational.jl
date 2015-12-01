module Relational

import Base: select, join

export Relation, select, where, join, groupby, agg, count

include("attribute.jl")

abstract AbstractRelation

immutable Relation <: AbstractRelation
    name::Symbol
    attrs::Tuple
    _lookup::Dict
    Relation(n, attrs) =
       new(n, attrs, Dict([name(a) => a for a in attrs]))
end
Relation(attrs) = Relation(:_, attrs)
fieldset(x::Relation) = x

include("source.jl") # Actual data sources, courtesy DataStreams

### Relation+Attr ###
immutable QualifiedAttr{T} <: Attr{T}
    relation::Relation
    attr::Attr{T}
end
name(x::QualifiedAttr) = name(x.attr)
Base.getindex(s::Relation, x) = QualifiedAttr(s, s._lookup[x])
Base.getindex(s::Relation, x::String) = s[symbol(x)]

Base.getindex(s::AbstractRelation, x) = fieldset(s)[x]
### Projection ###

immutable Select <: AbstractRelation
    from::AbstractRelation
    relation::Relation
end
select(from, fields::Tuple) = Select(from, Relation(fieldset(from).name, fields))
select(from, fields::Attr) = Select(from, Relation(fieldset(from).name, (fields,)))
fieldset(x::Relation) = x.relation

### Selection ###

immutable Where <: AbstractRelation
    source::AbstractRelation
    predicate::Attr{Bool}
end
where(source, attr) = Where(source, attr)
fieldset(x::Where) = fieldset(x.source)

### Join ###

immutable Join <: AbstractRelation
    l::AbstractRelation
    r::AbstractRelation
    link::Attr
end
join(l, r, link) = Join(l,r, link)
fieldset(x::Join) = fieldset(x.l) # TODO: Merge relation

### GroupBy ###

immutable GroupBy <: AbstractRelation
    source::AbstractRelation
    grouping::Tuple{Attr}
end
groupby(source, g) = GroupBy(source, g)
groupby(source, g::Attr) = GroupBy(source, (g,))
fieldset(x::GroupBy) = fieldset(x.source)

### Aggregate ###

immutable Aggregate <: AbstractRelation
    source::AbstractRelation
    aggregator::Aggregator
end
agg(r, a::Aggregator) = Aggregate(r, a)
agg(r, a::Function) = Aggregate(r, ReduceAgg(a))
fieldset(x::Aggregate) = fieldset(x.source)

Base.sum(r::AbstractRelation, f::Attr) = agg(r, Sum(f))
Base.mean(r::AbstractRelation, f::Attr) = agg(r, Avg(f))
count(r::AbstractRelation) = agg(r, Count())

include("show.jl")

end # module
