####################
# CARTESIAN COORDINATE SYSTEMS
##################
"""
    abstract type Coordinates{T <: Real, dim} end

An abstract type representing a coordinate system in a `dim`-dimensional space, where `T` is the type of the coordinate values (typically `Float64`, `Int` or `BigFloat`).
"""
abstract type Coordinates{T <: Real, dim} end

"""
    mutable struct CartesianCoordinates{T <: Real, dim} <: Coordinates{T, dim}

A mutable struct representing Cartesian coordinates in a `dim`-dimensional space, where `T` is the type of the coordinate values (typically `Float64`, `Int` or `BigFloat`).
"""
mutable struct CartesianCoordinates{T <: Real, dim} <: Coordinates{T, dim}
    xs::Vector{T}
    
    CartesianCoordinates(xs::Vector{T}) where {T <: Real} = new{T, length(xs)}(xs)
    CartesianCoordinates{T, dim}(xs::Vector{T}) where {T <: Real, dim} = new(xs)
    CartesianCoordinates{T, dim}() where {T <: Real, dim} = new(zeros(T, dim)) 
end

"""
    PlanarCoordinates{T} <: CartesianCoordinates{T, 2}

Type for 2D Cartesian coordinates, where `T` is the type of the coordinate values (typically `Float64`, `Int` or `BigFloat`).
"""
const PlanarCoordinates{T} = CartesianCoordinates{T, 2}
PlanarCoordinates(xs::Vector{T}) where {T <: Real} = PlanarCoordinates{T}(xs[1:2])

"""
    SpatialCoordinates{T} <: CartesianCoordinates{T, 3}

Type for 3D Cartesian coordinates, where `T` is the type of the coordinate values (typically `Float64`, `Int` or `BigFloat`).
"""
const SpatialCoordinates{T} = CartesianCoordinates{T, 3}
SpatialCoordinates(xs::Vector{T}) where {T <: Real} = SpatialCoordinates{T}(xs[1:3])

@forward CartesianCoordinates.xs LinearAlgebra.norm, Base.stack, Base.iterate
@forward_binary CartesianCoordinates.xs Base.isequal, Base.:(==)
@forward_binary_preserve_type CartesianCoordinates.xs Base.:(+), Base.:(-)
    

####################
# SPHERICAL COORDINATE SYSTEMS
##################
"""
    mutable struct GeneralSphericalCoordinates{T <: Real, Tr <: Union{Val{1}, T}, Tp <: Union{Nothing, T}, dim} <: Coordinates{T, dim}

A mutable struct representing spherical coordinates in a `dim`-dimensional space, where `T` is the type of the coordinate values (typically `Float64`, `Int` or `BigFloat`), `Tr` is the type of the radial coordinate (can be fixed to 1 for unit sphere), `Tp` is the type of the polar coordinate (can be `nothing` for 2D polar coordinates), and `dim` is the dimension of the coordinate system.
"""
mutable struct GeneralSphericalCoordinates{T <: Real, Tr <: Union{Val{1}, T}, Tp <: Union{Nothing, T}, dim} <: Coordinates{T, dim}
    r::Tr
    polar::Tp  # or θ, theta
    azi::T # or φ, phi, azimuth
end

# alias for full spherical coordinates
"""
    SphericalCoordinates{T} <: GeneralSphericalCoordinates{T, T, T, 3}

Type for full spherical coordinates in 3D space, where `T` is the type of the coordinate values (typically `Float64`, `Int` or `BigFloat`). The coordinates are represented as `(r, polar, azi)`.
"""
const SphericalCoordinates{T} = GeneralSphericalCoordinates{T, T, T, 3}
SphericalCoordinates(r::T, polar::T, azi::T) where {T <: Real} = SphericalCoordinates{T}(r, polar, azi)
SphericalCoordinates(r::Real, polar::Real, azi::Real) = SphericalCoordinates(promote(r, polar, azi)...)

# alias for points on sphere: r=1 fixed
"""
    SphereCoordinates{T} <: GeneralSphericalCoordinates{T, Val{1}, T, 3}

Type for spherical coordinates on the unit sphere in 3D space, where `T` is the type of the coordinate values (typically `Float64`, `Int` or `BigFloat`). The coordinates are represented as `(polar, azi)`, with `r` fixed to 1.
"""
const SphereCoordinates{T} = GeneralSphericalCoordinates{T, Val{1}, T, 3}
SphereCoordinates(polar::T, azi::T) where {T <: Real} = SphereCoordinates{T}(Val(1), polar, azi)
SphereCoordinates(polar::Real, azi::Real) = SphereCoordinates(promote(polar, azi)...)

# alias for polar 2D coordinates: polar = nothing fixed.
"""
    PolarCoordinates{T} <: GeneralSphericalCoordinates{T, T, Nothing, 2}

Type for polar coordinates in 2D space, where `T` is the type of the coordinate values (typically `Float64`, `Int` or `BigFloat`). The coordinates are represented as `(r, azi)`, with `polar` set to `nothing`.
"""
const PolarCoordinates{T} = GeneralSphericalCoordinates{T, T, Nothing, 2}
PolarCoordinates(r::T, azi::T) where {T <: Real} = PolarCoordinates{T}(r, nothing, azi)
PolarCoordinates(r::Real, azi::Real) = PolarCoordinates(promote(r, azi)...)

# alias for circle 2D coordinates: polar = nothing, r = 1 fixed.
"""
    CircleCoordinates{T} <: GeneralSphericalCoordinates{T, Val{1}, Nothing, 2}

Type for circular coordinates in 2D space, where `T` is the type of the coordinate values (typically `Float64`, `Int` or `BigFloat`). The coordinates are represented as `(azi)`, with `polar` set to `nothing` and `r` fixed to 1.
"""
const CircleCoordinates{T} = GeneralSphericalCoordinates{T, Val{1}, Nothing, 2}
CircleCoordinates(azi::T) where {T <: Real} = CircleCoordinates{T}(Val(1), nothing, azi)
