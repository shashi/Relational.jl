# Relational

**Work in progress.** Relational is a high-level library for expressing relational data operations.

Currently, DataStreams.jl interface can be used to create a relation which will act as the root node for queries. `DataStream(::Data.Source) -> Relation` can be used to create a Relation from a DataStreams.Data.Source object.

`Select`, `Where`, `Join`, `GroupBy`, `Aggregate` are relational-algebra nodes. The `schema` function returns a `Schema` object which can be used to construct queries.


Example:

```julia
using Relational, CSV

cd(Pkg.dir("Relational", "test"))
data = DataStreamRelation(:sample, CSV.read("sampledata.csv"))

query = select(where(data, data[:col2] + data[:col3] <= mean(data, data[:col4])), data[:col1])
# output: SELECT sample.col1 WHERE ((sample.col2 + sample.col3) <=  avg(sample.col4))

run(query) # this is still hypothetical
```

Possible future work may be:

- Query simplification (apply rules based on query types till fixed point is reached)
- ^ Can this be done at construction time?
- DataFrames, CSV and other database back ends

