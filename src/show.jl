import Base.show

function show(io::IO, x::Select)
    write(io, "SELECT ",
        join(UTF8String[sprint(io->show(io, x)) for x in x.relation.attrs], ", "))
    show(io, x.from)
end

show(io::IO, x::DataStreamRelation) = fieldset(x).name

function show(io::IO, x::Attr)
    write(io, string(name(x)))
end

function show(io::IO, x::QualifiedAttr)
    write(io, string(x.relation.name), ".", string(name(x.attr)))
end

function show(io::IO, x::Where)
    show(io, x.source)
    write(io, " WHERE ")
    show(io, x.predicate)
end

function show(io::IO, x::GroupBy)
    show(io, x.source)
    write(io, " GRPOUPBY ")
    show(io, x.grouping)
end

function show(io::IO, x::Aggregate)
    show(io, x.source)
    write(io, ' ')
    show(io, x.aggregator)
end

function show(io::IO, agg::Count)
    write(io, "count()")
end

function show(io::IO, agg::Avg)
    write(io, "avg(")
    show(io, agg.attr)
    write(io, ")")
end

function show(io::IO, agg::Sum)
    write(io, "sum(")
    show(io, agg.attr)
    write(io, ")")
end

function show(io::IO, a::QualifiedAttr)
    write(io, string(a.relation.name))
    write(io, '.')
    write(io, string(name(a)))
end

function show{op}(io::IO, a::BinOp{op})
    write(io, '(')
    show(io, a.l)
    write(io, ' ')
    write(io, op)
    write(io, ' ')
    show(io, a.r)
    write(io, ')')
end
