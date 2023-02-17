# BioModelsLoader.jl

making SBMLBioModelsRepository way better.

that one has a ton of deps to do benchmarking on every biomodel.
but thats a different usecase than just wanting to load a model.

the dependencies here are way lighter, nothing from sciml

maybe ill use this as a chance to do weak deps 

```julia
BioModelsLoader.get_biomodel("BIOMD0000000427")
```
