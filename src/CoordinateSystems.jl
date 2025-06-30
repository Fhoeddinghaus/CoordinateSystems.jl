module CoordinateSystems

using MacroTools, LinearAlgebra
import Base: show, convert, length, getproperty, setproperty!, propertynames, iterate

export 
    Coordinates, CartesianCoordinates, PlanarCoordinates, SpatialCoordinates, GeneralSphericalCoordinates, SphericalCoordinates, SphereCoordinates, PolarCoordinates, CircleCoordinates,

    trunc_dim




include("macros.jl")
include("types.jl")
include("helpers.jl")
include("base-ext-convert.jl")
include("base-ext.jl")


end # module CoordinateSystems
