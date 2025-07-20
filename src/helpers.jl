function print_type_styled(io::IO, Type::String, Parametric::String, Content::String)
    printstyled(io, Type, bold=true, color=:light_red)
    printstyled(io, Parametric, color=:light_red) 
    println(io, Content)
end

"""
    function trunc_dim(x::CartesianCoordinates{T, dim}, tdim) where {T <: Real, dim}

Truncates the dimension of a `CartesianCoordinates{T, dim}` instance `x` by removing the coordinate at index `tdim`. The resulting coordinates are returned as a new `CartesianCoordinates` instance with one less dimension.
"""
function trunc_dim(x::CartesianCoordinates{T, dim}, tdim) where {T <: Real, dim}
    xs = copy(x.xs)
    deleteat!(xs, tdim)
    return CartesianCoordinates(xs)
end