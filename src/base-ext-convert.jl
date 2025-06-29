####################
# CONVERTERS
##################
function Base.convert(::Type{CartesianCoordinates{T1, dim1}}, x::CartesianCoordinates{T, dim}) where {T1 <: Real, dim1, T <: Real, dim}
    if T == T1
        return resize!(x, dim1)
    else
        xs = T1.(x.xs)
        resize!(xs, dim1)
        xs[dim+1:dim1] .= 0
        return CartesianCoordinates{T1, dim1}(xs)
    end
end

function Base.convert(::Type{Vector}, x::CartesianCoordinates{T, dim}) where {T <: Real, dim}
    return x.xs
end

# converts
# CartesianCoordinates, GeneralSphericalCoordinates
# SphericalCoordinates, SphereCoordinates, PolarCoordinates, CircleCoordinates

# 1. CartesianCoordinates:
# 1a. GSC → CC
function Base.convert(::Type{T}, g::GeneralSphericalCoordinates) where {T <: CartesianCoordinates}
    dim = g.dim
    if dim == 2
        r = (g isa CircleCoordinates ? 1 : g.r)
        xs = [
            r * cos(g.azi),
            r * sin(g.azi)
        ]
        return CartesianCoordinates{eltype(xs), 2}(xs)
    elseif dim == 3
        r = (g isa SphereCoordinates ? 1 : g.r)
        xs = [
            r * sin(g.polar) * cos(g.azi),
            r * sin(g.polar) * sin(g.azi),
            r * cos(g.polar)
        ]
        return CartesianCoordinates{eltype(xs), 3}(xs)
    else
        error("type ", typeof(g), " has invalid dimension to convert into CartesianCoordinates")
    end
end

# 1b. CC2 → CiC, PC
function Base.convert(::Type{T}, x::CartesianCoordinates; truncate::Bool=false) where {T <: Union{CircleCoordinates, PolarCoordinates}}
    dim = x.dim
    if dim != 2
        throw(DimensionMismatch("can't convert $(typeof(x)) to $T. " *
        "Use resize!, trunc_dim or convert first to reduce/elevate $(typeof(x))" *
        " to a CartesianCoordinates{$(eltype(x.xs)), 2}."))
    end
    
    r(x::Vector{T1}) where {T1 <: Real} = sqrt(sum(x .^2)) 
    φ(x::Vector{T1}) where {T1 <: Real} = atan(x[2],x[1])
    
    if T == CircleCoordinates
        R = (truncate ? 1 : r(x.xs)) 
        if R ≈ 1 
            azi = φ(x.xs)
            return CircleCoordinates(azi)
        else
            error("type ", typeof(x), " can only be converted to $T if it has norm ≈ 1 (currently: norm = $R) or the truncate option is set to project onto the unit circle.")
        end
    else # PolarCoordinates
        R = r(x.xs)
        azi = φ(x.xs)
        return PolarCoordinates(R, azi)
    end
end

# 1c. CC3 → SC, SiC
function Base.convert(::Type{T}, x::CartesianCoordinates; truncate::Bool=false) where {T <: Union{SphereCoordinates, SphericalCoordinates}}
    dim = x.dim
    if dim != 3
        throw(DimensionMismatch("can't convert $(typeof(x)) to $T. " *
        "Use resize!, trunc_dim or convert first to reduce/elevate $(typeof(x))" *
        " to a CartesianCoordinates{$(eltype(x.xs)), 3}."))
    end
    
    r(x::Vector{T1}) where {T1 <: Real} = sqrt(sum(x .^2)) 
    φ(x::Vector{T1}) where {T1 <: Real} = atan(x[2],x[1])
    θ(x::Vector{T1}, r::Real) where {T1 <: Real} = acos(x[3]/r)
    
    if T == SphereCoordinates
        R = r(x.xs)
        if R ≈ 1 || truncate
            azi = φ(x.xs)
            polar = θ(x.xs, R)
            return SphereCoordinates(polar, azi)
        else
            error("type ", typeof(x), " can only be converted to $T if it has norm ≈ 1 (currently: norm = $R) or the truncate option is set to project onto the unit sphere.")
        end
    else # SphericalCoordinates
        R = r(x.xs)
        azi = φ(x.xs)
        polar = θ(x.xs, R)
        return SphericalCoordinates(R, polar, azi)
    end
end

# 2. Spherical:
# 2a. SiC ↔ SC
function Base.convert(::Type{SphereCoordinates}, b::SphericalCoordinates{T}; truncate::Bool=false) where {T <: Real}
    if b.r ≈ 1 || truncate
        return SphereCoordinates(b.polar, b.azi)
    else
        error("type ", typeof(b), " can only be converted to SphereCoordinates{$T} if it has radius ≈ 1 or the truncate option is set to project onto the unit sphere.") 
    end
end

Base.convert(::Type{SphericalCoordinates}, s::SphereCoordinates) = SphericalCoordinates(1, s.polar, s.azi)

# 2b. PC ↔ CiC
function Base.convert(::Type{CircleCoordinates}, p::PolarCoordinates{T}; truncate::Bool=false) where {T <: Real}
    if p.r ≈ 1 || truncate
        return CircleCoordinates(p.azi)
    else
        error("type ", typeof(b), " can only be converted to CircleCoordinates{$T} if it has radius ≈ 1 or the truncate option is set to project onto the unit circle.") 
    end
end

Base.convert(::Type{PolarCoordinates}, c::CircleCoordinates) = PolarCoordinates(1, c.azi)

# 2c. SiC/SC ↔ PC/CiC
function Base.convert(::Type{T1}, g::T2; truncate::Bool=false) where {T1 <: Union{PolarCoordinates, CircleCoordinates}, T2 <: Union{SphericalCoordinates, SphereCoordinates}}
    if T1 == PolarCoordinates
        g = convert(SphericalCoordinates, g)
        x3 = convert(CartesianCoordinates, g)
        R = sqrt(sum(x3.x^2 + x3.y^2))
        return PolarCoordinates(R, g.azi)
    else # CircleCoordinates
        g = (g isa SphericalCoordinates ? convert(SphereCoordinates, g, truncate=truncate) : g)
        return CircleCoordinates(g.azi)
    end
end

function Base.convert(::Type{T1}, g::T2; truncate::Bool=false) where {T1 <: Union{SphericalCoordinates, SphereCoordinates}, T2 <: Union{PolarCoordinates, CircleCoordinates}}
    if T1 == SphericalCoordinates
        g = convert(PolarCoordinates, g)
        return SphericalCoordinates(g.r, π/2, g.azi)
    else # SphereCoordinates
        g = (g isa PolarCoordinates ? convert(CircleCoordinates, g, truncate=truncate) : g)
        return SphereCoordinates(π/2, g.azi)
    end
end