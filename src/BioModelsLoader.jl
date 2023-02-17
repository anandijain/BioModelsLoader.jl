module BioModelsLoader

using JSON3, Downloads, SBML, URIs
using Base.Threads

const ALL_ODE_MODELS_SEARCH = "*:* AND modellingapproach:\"Ordinary differential equation model\"&domain=biomodels"
SEARCH_URI = URI("https://www.ebi.ac.uk/biomodels/search")

function default_convert_function(level, version)
    doc -> begin
        set_level_and_version(level, version)(doc)
        convert_promotelocals_expandfuns(doc)
    end
end

DEFAULT_CONVERT_FUNCTION = default_convert_function(3, 2)

function string_from_url(url; headers=[])
    io = IOBuffer()
    Downloads.download(url, io; headers)
    String(take!(io))
end

function readSBMLFromURL(url; conv_f=DEFAULT_CONVERT_FUNCTION)
    SBML.readSBMLFromString(string_from_url(url), conv_f)
end

biomodel_files_url(model_id) = "https://www.ebi.ac.uk/biomodels/model/files/$(model_id)"

function biomodel_url(id)
    j = JSON3.read(string_from_url(biomodel_files_url(id); headers=["accept" => "application/json"]))
    haskey(j, "errorMessage") && error(repr(j))
    fn = replace(j.main[1]["name"], " " => "+") # questionable
    "https://www.ebi.ac.uk/biomodels/model/download/$(id)?filename=$(fn)"
end

function get_biomodel(id; conv_f=DEFAULT_CONVERT_FUNCTION)
    # change this to SBML.readSBMLFromURL once https://github.com/LCSB-BioCore/SBML.jl/pull/241 is merged
    readSBMLFromURL(biomodel_url(id); conv_f)
end

download_biomodel(id) = string_from_url(biomodel_url(id))

function query_endpoint(query; base=SEARCH_URI)
    JSON3.read(string_from_url(string(URI(base; query))))
end

"returns a json index of all the sbml biomodels"
function biomodels_index(; search_term="sbml", query=["query" => search_term, "format" => "json"])
    m = query_endpoint(query).matches
    js = []
    Threads.@threads for i in 0:100:(m+(100-(m%100)))
        @info i
        query = ["query" => search_term, "offset" => i, "numResults" => 100, "format" => "json"]
        append!(js, query_endpoint(query).models)
    end
    js
end

end # module BioModelsLoader
