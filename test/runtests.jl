using BioModelsLoader, Test, SBML

id = "MODEL8568434338"
m = BioModelsLoader.readSBMLBioModel(id)
m = BioModelsLoader.readSBMLBioModel(id; conv_f=BioModelsLoader.default_convert_function(3, 1))
@test length(m.reactions) == 249

index = BioModelsLoader.biomodels_index()
search_term = "*:* AND modellingapproach:\"Ordinary differential equation model\"&domain=biomodels"
query = ["query" => BioModelsLoader.ALL_ODE_MODELS_SEARCH, "format" => "json"]

j = BioModelsLoader.query_endpoint(query)
query = ["query" => "sbml", "format" => "json"]
j2 = BioModelsLoader.query_endpoint(query)
@info "theres $(j.matches) ODE models and $(j2.matches) SBML models"

# this is duplicating api calls
sbmls = BioModelsLoader.biomodels_index()
odes = BioModelsLoader.biomodels_index(; search_term=BioModelsLoader.ALL_ODE_MODELS_SEARCH)

mkpath("logs/")
JSON3.write("logs/sbmls.json", sbmls)
JSON3.write("logs/odes.json", odes)
