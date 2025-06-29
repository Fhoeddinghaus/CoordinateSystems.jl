####################
# CARTESIAN COORDINATE SYSTEMS
##################
abstract type Coordinates{T <: Real, dim} end

mutable struct CartesianCoordinates{T <: Real, dim} <: Coordinates{T, dim}
    xs::Vector{T}
    
    CartesianCoordinates(xs::Vector{T}) where {T <: Real} = new{T, length(xs)}(xs)
    CartesianCoordinates{T, dim}(xs::Vector{T}) where {T <: Real, dim} = new(xs)
    CartesianCoordinates{T, dim}() where {T <: Real, dim} = new(zeros(T, dim)) 
end

const PlanarCoordinates{T} = CartesianCoordinates{T, 2}
PlanarCoordinates(xs::Vector{T}) where {T <: Real} = PlanarCoordinates{T}(xs[1:2])

const SpatialCoordinates{T} = CartesianCoordinates{T, 3}
SpatialCoordinates(xs::Vector{T}) where {T <: Real} = SpatialCoordinates{T}(xs[1:3])

@forward CartesianCoordinates.xs LinearAlgebra.norm, Base.stack, Base.iterate
@forward_binary CartesianCoordinates.xs Base.isequal, Base.:(==)
@forward_binary_preserve_type CartesianCoordinates.xs Base.:(+), Base.:(-)
    

####################
# SPHERICAL COORDINATE SYSTEMS
##################
mutable struct GeneralSphericalCoordinates{T <: Real, Tr <: Union{Val{1}, T}, Tp <: Union{Nothing, T}, dim} <: Coordinates{T, dim}
    r::Tr
    polar::Tp  # or θ, theta
    azi::T # or φ, phi, azimuth
end

# alias for full spherical coordinates
const SphericalCoordinates{T} = GeneralSphericalCoordinates{T, T, T, 3}
SphericalCoordinates(r::T, polar::T, azi::T) where {T <: Real} = SphericalCoordinates{T}(r, polar, azi)
SphericalCoordinates(r::Real, polar::Real, azi::Real) = SphericalCoordinates(promote(r, polar, azi)...)

# alias for points on sphere: r=1 fixed
const SphereCoordinates{T} = GeneralSphericalCoordinates{T, Val{1}, T, 3}
SphereCoordinates(polar::T, azi::T) where {T <: Real} = SphereCoordinates{T}(Val(1), polar, azi)
SphereCoordinates(polar::Real, azi::Real) = SphereCoordinates(promote(polar, azi)...)

# alias for polar 2D coordinates: polar = nothing fixed.
const PolarCoordinates{T} = GeneralSphericalCoordinates{T, T, Nothing, 2}
PolarCoordinates(r::T, azi::T) where {T <: Real} = PolarCoordinates{T}(r, nothing, azi)
PolarCoordinates(r::Real, azi::Real) = PolarCoordinates(promote(r, azi)...)

# alias for circle 2D coordinates: polar = nothing, r = 1 fixed.
const CircleCoordinates{T} = GeneralSphericalCoordinates{T, Val{1}, Nothing, 2}
CircleCoordinates(azi::T) where {T <: Real} = CircleCoordinates{T}(Val(1), nothing, azi)
