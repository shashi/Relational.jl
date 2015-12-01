### DataStreams interface ###

using DataStreams

immutable DataStreamRelation{T<:Data.Source} <: AbstractRelation
    source::T
    relation::Relation
end

function convert_fieldset(source, name=:_)
    sch = Data.schema(source)
    Relation(name, ([Field{sch.types[i]}(symbol(sch.header[i]))
        for i=1:length(sch.header)]...,))
end

Relation(name::Symbol, source::Data.Source) = DataStreamRelation(source, convert_fieldset(source, name))
Relation(source::Data.Source) = DataStreamRelation(source, convert_fieldset(source))
fieldset(x::DataStreamRelation) = x.relation
Base.convert(::Type{Relation}, source::Data.Source) = DataStreamRelation(source)
