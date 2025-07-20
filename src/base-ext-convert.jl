####################
# CONVERTERS
##################
"""
    function Base.convert(::Type{CartesianCoordinates{T1, dim1}}, x::CartesianCoordinates{T, dim}) where {T1 <: Real, dim1, T <: Real, dim}

Converts a `CartesianCoordinates{T, dim}` to `CartesianCoordinates{T1, dim1}` by resizing the vector and converting the elements to type `T1`. If `dim1` is greater than `dim`, the additional elements are set to zero.
"""
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

"""
    function Base.convert(::Type{Vector}, x::CartesianCoordinates{T, dim}) where {T <: Real, dim}

Converts a `CartesianCoordinates{T, dim}` to a `Vector{T}` by extracting the coordinate values.
"""
function Base.convert(::Type{Vector}, x::CartesianCoordinates{T, dim}) where {T <: Real, dim}
    return x.xs
end

# converts
# CartesianCoordinates, GeneralSphericalCoordinates
# SphericalCoordinates, SphereCoordinates, PolarCoordinates, CircleCoordinates

# 1. CartesianCoordinates:
# 1a. GSC → CC
"""
    function Base.convert(::Type{T}, g::GeneralSphericalCoordinates) where {T <: CartesianCoordinates}

Converts a `GeneralSphericalCoordinates` to a `CartesianCoordinates{T, dim}` where `dim` is either 2 or 3. The conversion uses the spherical coordinates to compute the Cartesian coordinates.
"""
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
"""
    function Base.convert(::Type{T}, x::CartesianCoordinates; truncate::Bool=false) where {T <: Union{CircleCoordinates, PolarCoordinates}}

Converts a `CartesianCoordinates` with dimension 2 to either `CircleCoordinates` or `PolarCoordinates`. If `truncate` is set to `true`, the conversion projects the coordinates onto the unit circle or unit polar coordinates, respectively. If `truncate` is `false`, the conversion requires the Cartesian coordinates to have a norm close to 1.
"""
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
"""
    function Base.convert(::Type{T}, x::CartesianCoordinates; truncate::Bool=false) where {T <: Union{SphereCoordinates, SphericalCoordinates}}

Converts a `CartesianCoordinates` with dimension 3 to either `SphereCoordinates` or `SphericalCoordinates`. If `truncate` is set to `true`, the conversion projects the coordinates onto the unit sphere or spherical coordinates, respectively. If `truncate` is `false`, the conversion requires the Cartesian coordinates to have a norm close to 1.
"""
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
"""
    function Base.convert(::Type{SphereCoordinates}, b::SphericalCoordinates{T}; truncate::Bool=false) where {T <: Real}

Converts a `SphericalCoordinates{T}` to `SphereCoordinates{T}`. If the radius `b.r` is approximately 1 or `truncate` is set to `true`, the conversion projects the coordinates onto the unit sphere. Otherwise, an error is raised.
"""
function Base.convert(::Type{SphereCoordinates}, b::SphericalCoordinates{T}; truncate::Bool=false) where {T <: Real}
    if b.r ≈ 1 || truncate
        return SphereCoordinates(b.polar, b.azi)
    else
        error("type ", typeof(b), " can only be converted to SphereCoordinates{$T} if it has radius ≈ 1 or the truncate option is set to project onto the unit sphere.") 
    end
end

"""
    function Base.convert(::Type{SphericalCoordinates}, s::SphereCoordinates)

Converts a `SphereCoordinates` to `SphericalCoordinates`. The radius is set to 1.
"""
Base.convert(::Type{SphericalCoordinates}, s::SphereCoordinates) = SphericalCoordinates(1, s.polar, s.azi)

# 2b. PC ↔ CiC
"""
    function Base.convert(::Type{CircleCoordinates}, p::PolarCoordinates{T}; truncate::Bool=false) where {T <: Real}

Converts a `PolarCoordinates{T}` to `CircleCoordinates{T}`. If the radius `p.r` is approximately 1 or `truncate` is set to `true`, the conversion projects the coordinates onto the unit circle. Otherwise, an error is raised.
"""
function Base.convert(::Type{CircleCoordinates}, p::PolarCoordinates{T}; truncate::Bool=false) where {T <: Real}
    if p.r ≈ 1 || truncate
        return CircleCoordinates(p.azi)
    else
        error("type ", typeof(b), " can only be converted to CircleCoordinates{$T} if it has radius ≈ 1 or the truncate option is set to project onto the unit circle.") 
    end
end

"""
    function Base.convert(::Type{PolarCoordinates}, c::CircleCoordinates)

Converts a `CircleCoordinates` to `PolarCoordinates`. The radius is set to 1.
"""
Base.convert(::Type{PolarCoordinates}, c::CircleCoordinates) = PolarCoordinates(1, c.azi)

# 2c. SiC/SC ↔ PC/CiC
"""
    function Base.convert(::Type{T1}, g::T2; truncate::Bool=false) where {T1 <: Union{PolarCoordinates, CircleCoordinates}, T2 <: Union{SphericalCoordinates, SphereCoordinates}}

Converts `SphericalCoordinates` or `SphereCoordinates` to `PolarCoordinates` or `CircleCoordinates`. 
"""
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

"""
    function Base.convert(::Type{T1}, g::T2; truncate::Bool=false) where {T1 <: Union{SphericalCoordinates, SphereCoordinates}, T2 <: Union{PolarCoordinates, CircleCoordinates}}

Converts `PolarCoordinates` or `CircleCoordinates` to `SphericalCoordinates` or `SphereCoordinates`.
"""
function Base.convert(::Type{T1}, g::T2; truncate::Bool=false) where {T1 <: Union{SphericalCoordinates, SphereCoordinates}, T2 <: Union{PolarCoordinates, CircleCoordinates}}
    if T1 == SphericalCoordinates
        g = convert(PolarCoordinates, g)
        return SphericalCoordinates(g.r, π/2, g.azi)
    else # SphereCoordinates
        g = (g isa PolarCoordinates ? convert(CircleCoordinates, g, truncate=truncate) : g)
        return SphereCoordinates(π/2, g.azi)
    end
end