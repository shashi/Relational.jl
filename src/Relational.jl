module Relational

import Base: select, join

export Schema, select, where, join, groupby, agg, count

include("attribute.jl")

abstract Relation

immutable Schema <: Relation
    name::Symbol
    attrs::Tuple
    _lookup::Dict
    Schema(n, attrs) =
       new(n, attrs, Dict([name(a) => a for a in attrs]))
end
Schema(attrs) = Schema(:_, attrs)
schema(x::Schema) = x
include("source.jl") # Actual data sources, courtesy DataStreams

### Schema+Attr ###
immutable QualifiedAttr{T} <: Attr{T}
    schema::Schema
    attr::Attr{T}
end
name(x::QualifiedAttr) = name(x.attr)
Base.getindex(s::Schema, x) = QualifiedAttr(s, s._lookup[x])
Base.getindex(s::Schema, x::String) = s[symbol(x)]

Base.getindex(s::Relation, x) = schema(s)[x]
### Projection ###

immutable Select <: Relation
    from::Relation
    schema::Schema
end
select(from, fields::Tuple) = Select(from, Schema(schema(from).name, fields))
select(from, fields::Attr) = Select(from, Schema(schema(from).name, (fields,)))
schema(x::Schema) = x.schema

### Selection ###

immutable Where <: Relation
    source::Relation
    predicate::Attr{Bool}
end
where(source, attr) = Where(source, attr)
schema(x::Where) = schema(x.source)

### Join ###

immutable Join <: Relation
    l::Relation
    r::Relation
    link::Attr
end
join(l, r, link) = Join(l,r, link)
schema(x::Join) = schema(x.l) # TODO: Merge schema

### GroupBy ###

immutable GroupBy <: Relation
    source::Relation
    grouping::Tuple{Attr}
end
groupby(source, g) = GroupBy(source, g)
groupby(source, g::Attr) = GroupBy(source, (g,))
schema(x::GroupBy) = schema(x.source)

### Aggregate ###

immutable Aggregate <: Relation
    source::Relation
    aggregator::Aggregator
end
agg(r, a::Aggregator) = Aggregate(r, a)
agg(r, a::Function) = Aggregate(r, ReduceAgg(a))
schema(x::Aggregate) = schema(x.source)

Base.sum(r::Relation, f::Attr) = agg(r, Sum(f))
Base.mean(r::Relation, f::Attr) = agg(r, Avg(f))
count(r::Relation) = agg(r, Count())

include("show.jl")
end # module
