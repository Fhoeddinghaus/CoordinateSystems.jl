push!(LOAD_PATH,"../src/")

using Documenter, CoordinateSystems

makedocs(
    sitename="CoordinateSystems.jl",
    authors = "Lilith Emilia Höddinghaus",
    pages = [
        "index.md",
    ],
)

# show documentation locally after generating with 
#   python3 -m http.server --bind localhost