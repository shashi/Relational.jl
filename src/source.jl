### DataStreams interface ###

using DataStreams

export DataStreamRelation

immutable DataStreamRelation{T<:Data.Source} <: Relation
    source::T
    schema::Schema
end

function convert_schema(source, name=:_)
    sch = Data.schema(source)
    Schema(name, ([Field{sch.types[i]}(symbol(sch.header[i]))
        for i=1:length(sch.header)]...,))
end

DataStreamRelation(name::Symbol, source) = DataStreamRelation(source, convert_schema(source, name))
DataStreamRelation(source) = DataStreamRelation(source, convert_schema(source))
schema(x::DataStreamRelation) = x.schema
Base.convert(::Type{Relation}, source::Data.Source) = DataStreamRelation(source)
