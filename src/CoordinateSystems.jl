module CoordinateSystems

using MacroTools
import Base: show, convert, length, getproperty, setproperty!, propertynames, iterate

export 
    Coordinates, CartesianCoordinates, PlanarCoordinates, SpatialCoordinates, GeneralSphericalCoordinates, SphericalCoordinates, SphereCoordinates, PolarCoordinates, CircleCoordinates,

    trunc_dim,

    StereographicCoordinates,
    projection




include("macros.jl")
include("types.jl")
include("helpers.jl")
include("base-ext-convert.jl")
include("stereographic-projection.jl")


end # module CoordinateSystems
