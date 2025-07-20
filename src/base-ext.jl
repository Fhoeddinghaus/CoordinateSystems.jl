# other extensions to Base
"""
    function Base.length(x::Coordinates{T, dim}) where {T <: Real, dim}

Returns the dimension of the coordinate system represented by `x`, which is an instance of `Coordinates{T, dim}`.
"""
function Base.length(x::Coordinates{T, dim}) where {T <: Real, dim}
    return dim
end

"""
    function Base.getproperty(x::CartesianCoordinates{T, dim}, i::Symbol) where {T <: Real, dim}

Returns the value of the property `i` from the `CartesianCoordinates{T, dim}` instance `x`. The properties include `:dim`, `:xs`, and coordinate values like `:x`, `:y`, `:z`, or `:xN` for dimensions greater than 3.
"""
function Base.getproperty(x::CartesianCoordinates{T, dim}, i::Symbol) where {T <: Real, dim}
    xs = getfield(x, :xs)
    
    if i == :dim
        return dim
    elseif i == :xs
        return xs
    elseif i == :x
        if  dim > 0
            return xs[1]
        else
            throw(BoundsError(x, 1)) 
        end
    elseif i == :y
        if dim > 1
            return xs[2]
        else
            throw(BoundsError(x, 2)) 
        end
    elseif i == :z
        if dim > 2
            return xs[3]
        else
            throw(BoundsError(x, 3)) 
        end
    elseif String(i)[1] == 'x' && !(0 in isnumeric.(Vector{Char}(String(i)[2:end])))
        j = parse(Int, String(i)[2:end])
        if 0 < j <= dim
            return xs[j]
        else
            throw(BoundsError(x, j)) 
        end
    else
        error("type CartesianCoordinates has no field $i")
    end
    return nothing
end

"""
    function Base.setproperty!(x::CartesianCoordinates{T, dim}, i::Symbol, val) where {T <: Real, dim}

Sets the property `i` of the `CartesianCoordinates{T, dim}` instance `x` to the value `val`. The properties include `:dim`, `:xs`, and coordinate values like `:x`, `:y`, `:z`, or `:xN` for dimensions greater than 3. If an invalid property is specified, an error is raised.
"""
function Base.setproperty!(x::CartesianCoordinates{T, dim}, i::Symbol, val) where {T <: Real, dim}
    if i == :dim
        error("Dimension cannot be changed directly. Use resize! or trunc_dim.")
    elseif i == :xs
        setfield!(x, :xs, val)
    elseif i == :x
        if  dim > 0
            x.xs[1] = val
        else
            throw(BoundsError(x, 1)) 
        end
    elseif i == :y
        if dim > 1
            x.xs[2] = val
        else
            throw(BoundsError(x, 2)) 
        end
    elseif i == :z
        if dim > 2
            x.xs[3] = val
        else
            throw(BoundsError(x, 3)) 
        end
    elseif String(i)[1] == 'x' && !(0 in isnumeric.(Vector{Char}(String(i)[2:end])))
        j = parse(Int, String(i)[2:end])
        if 0 < j <= dim
            x.xs[j] = val
        else
            throw(BoundsError(x, j)) 
        end
    else
        error("type CartesianCoordinates has no field $i")
    end
    return nothing
end

"""
    function Base.getindex(x::CartesianCoordinates{T, dim}, keys::Union{Int, Symbol, AbstractVector{Int}})  where {T <: Real, dim}

Returns the value of the coordinate or property specified by `keys` from the `CartesianCoordinates{T, dim}` instance `x`. The `keys` can be an integer index, a symbol representing a property, or an array of indices.
"""
function Base.getindex(x::CartesianCoordinates{T, dim}, keys::Union{Int, Symbol, AbstractVector{Int}})  where {T <: Real, dim}
    if keys isa AbstractVector
        return x.xs[keys]
    else
        if keys isa Int
            keys = Symbol("x$keys")
        end
        return getproperty(x, keys)
    end
end

"""
    function Base.setindex!(x::CartesianCoordinates{T, dim}, val, keys::Union{Int, Symbol, AbstractVector{Int}}) where {T <: Real, dim}

Sets the value of the coordinate or property specified by `keys` in the `CartesianCoordinates{T, dim}` instance `x` to `val`. The `keys` can be an integer index, a symbol representing a property, or an array of indices. If an invalid property is specified, an error is raised.
"""
function Base.setindex!(x::CartesianCoordinates{T, dim}, val, keys::Union{Int, Symbol, AbstractVector{Int}}) where {T <: Real, dim}
    if keys isa AbstractVector
        x.xs[keys] = val
    else
        if keys isa Int
            keys = Symbol("x$keys")
        end
        setproperty!(x, keys, val)
    end
end

"""
    function Base.resize!(x::CartesianCoordinates{T, dim}, new_dim::Int) where {T <: Real, dim}

Resizes the `CartesianCoordinates{T, dim}` instance `x` to a new dimension `new_dim`. If `new_dim` is greater than the current dimension, the additional elements are set to zero. If `new_dim` is less than the current dimension, the excess elements are removed.
"""
function Base.resize!(x::CartesianCoordinates{T, dim}, new_dim::Int) where {T <: Real, dim}
    xs = copy(x.xs)
    resize!(xs, new_dim)
    xs[dim+1:new_dim] .= 0
    return CartesianCoordinates(xs)
end

"""
    function Base.propertynames(x::CartesianCoordinates{T, dim}) where {T <: Real, dim}

Returns a tuple of property names for the `CartesianCoordinates{T, dim}` instance `x`. The properties include `:xs`, `:dim`, and coordinate values like `:x`, `:y`, `:z`, or `:xN` for dimensions greater than 3.
"""
function Base.propertynames(x::CartesianCoordinates{T, dim}) where {T <: Real, dim}
    props = Symbol[:xs, :dim]
    if dim > 0 push!(props, :x, :x1) end
    if dim > 1 push!(props, :y, :x2) end
    if dim > 2 push!(props, :z, :x3) end
    for i in 4:dim
        push!(props, Symbol("x$i")) 
    end
    return Tuple(props)
end

"""
    function Base.show(io::IO, x::Coordinates)

Displays the `Coordinates{T, dim}` instance `x` in a human-readable format. The output includes the type of coordinates, the type of the coordinate values, and the dimension.
"""
function Base.show(io::IO, x::CartesianCoordinates{T, dim}) where {T <: Real, dim}
    if x isa PlanarCoordinates
        printstyled(io, "PlanarCoordinates", bold=true, color=:light_red)
    elseif x isa SpatialCoordinates
        printstyled(io, "SpatialCoordinates", bold=true, color=:light_red)
    else
        printstyled(io, "CartesianCoordinates", bold=true, color=:light_red)
    end
    printstyled(io, "{", T, ", dim=", dim,"}", color=:light_red)
    print(io, "(")
    if 0 < dim <= 3
        if dim > 0
            print(io, "x=", x.x)
        end
        if dim > 1
            print(io, ", y=", x.y)
        end
        if dim > 2
            print(io, ", z=", x.z)
        end
    elseif dim > 3
        print(io, "x1=", x.x)
        for i in 2:dim
            print(io, ", x$i=", x.xs[i]) 
        end 
    end 
    println(io, ")")
end 

"""
    function Base.iterate(s::GeneralSphericalCoordinates{T, Tr, Tp, dim}, state::Int64=1) where {T, Tr, Tp, dim}

Iterates over the properties of a `GeneralSphericalCoordinates{T, Tr, Tp, dim}` instance `s`.
Order: `r`, `polar`, `azi`.
"""
function Base.iterate(s::GeneralSphericalCoordinates{T, Tr, Tp, dim}, state::Int64=1) where {T, Tr, Tp, dim}
    if state == 1
        return (s.r, state+1)
    elseif state == 2 < dim
        return (s.polar, state+1)
    elseif state == dim
        return (s.azi, state +1)
    elseif state > dim
        return nothing
    end   
end

"""
    function Base.propertynames(s::GeneralSphericalCoordinates{T, Tr, Tp, dim}) where {T, Tr, Tp, dim}    

Returns a tuple of property names for the `GeneralSphericalCoordinates{T, Tr, Tp, dim}` instance `s`. The properties include `:r`, `:polar` (or `:θ`, `:theta`), and `:azi` (or `:φ`, `:phi`, `:azimuth`). The dimension is also included as `:dim`.
"""
function Base.propertynames(s::GeneralSphericalCoordinates{T, Tr, Tp, dim}) where {T, Tr, Tp, dim} 
    props = Symbol[:r]
    if dim == 3
        push!(props, :polar, :θ, :theta)
    end
    push!(props, :azi, :φ, :phi, :azimuth, :dim)
    return Tuple(props)
end

"""
    function Base.getproperty(s::GeneralSphericalCoordinates{T, Tr, Tp, dim}, i::Symbol) where {T, Tr, Tp, dim}

Returns the value of the property `i` from the `GeneralSphericalCoordinates{T, Tr, Tp, dim}` instance `s`. The properties include `:r`, `:polar` (or `:θ`, `:theta`), and `:azi` (or `:φ`, `:phi`, `:azimuth`). The dimension is also included as `:dim`. If an invalid property is specified, an error is raised.
"""
function Base.getproperty(s::GeneralSphericalCoordinates{T, Tr, Tp, dim}, i::Symbol) where {T, Tr, Tp, dim}
    if i in (:θ, :theta, :polar)
        i = :polar
    elseif i in (:φ, :phi, :azimuth, :azi)
        i = :azi
    elseif i == :dim
        return dim
    elseif i == :r
        r = getfield(s, :r)
        if r == Val(1)
            return 1
        else
            return r
        end
    end
    
    if hasproperty(s, i)
        return getfield(s, i)
    else
        throw(error("type ", typeof(s) ," has no field $i")) 
    end
end

"""
    function Base.setproperty!(s::GeneralSphericalCoordinates{T, Tr, Tp, dim}, i::Symbol, val) where {T, Tr, Tp, dim}

Sets the property `i` of the `GeneralSphericalCoordinates{T, Tr, Tp, dim}` instance `s` to the value `val`. The properties include `:r`, `:polar` (or `:θ`, `:theta`), and `:azi` (or `:φ`, `:phi`, `:azimuth`). If an invalid property is specified, an error is raised.
"""
function Base.setproperty!(s::GeneralSphericalCoordinates{T, Tr, Tp, dim}, i::Symbol, val) where {T, Tr, Tp, dim}
    if i in (:polar, :θ, :theta)
        if dim == 3
            setfield!(s, :polar, val)
        else
            error(typeof(s), " is ", dim, "D and has no polar angle.")
        end
    elseif i in (:azi, :φ, :phi, :azimuth)
        setfield!(s, :azi, val)
    elseif hasproperty(s, i)
        setfield!(s, i, val)
    else
        throw(error("type ", typeof(s), " has no field $i")) 
    end
end

Base.show(io::IO, b::SphericalCoordinates{T}) where {T <: Real} = print_type_styled(io, 
    "SphericalCoordinates", 
    "{$T}", 
    "(r=$(b.r), θ(polar)=$(b.polar) rad, φ(azimuth)=$(b.azi) rad)"
)

Base.show(io::IO, s::SphereCoordinates{T}) where {T <: Real} = print_type_styled(io, 
    "SphereCoordinates", 
    "{$T}", 
    "(r=1, θ(polar)=$(s.polar) rad, φ(azimuth)=$(s.azi) rad)"
)

Base.show(io::IO, p::PolarCoordinates{T}) where {T <: Real} = print_type_styled(io, 
    "PolarCoordinates", 
    "{$T}", 
    "(r=$(p.r), φ(azimuth)=$(p.azi) rad)"
)

Base.show(io::IO, c::CircleCoordinates{T}) where {T <: Real} = print_type_styled(io, 
    "CircleCoordinates", 
    "{$T}", 
    "(φ=$(c.azi) rad)"
)