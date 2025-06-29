"""
    @forward T.x functions...

Define methods for `functions` on type `T`, which call the relevant function
on the field `x`.

# Example

```julia
struct Wrapper
    x
end

@forward Wrapper.x  Base.sqrt                                  # now sqrt(Wrapper(4.0)) == 2.0
@forward Wrapper.x  Base.length, Base.getindex, Base.iterate   # several forwarded functions are put in a tuple
@forward Wrapper.x (Base.length, Base.getindex, Base.iterate)  # equivalent to above
```
"""
macro forward(ex, fs)
  @capture(ex, T_.field_) || error("Syntax: @forward T.x f, g, h")
  T = esc(T)
  fs = isexpr(fs, :tuple) ? map(esc, fs.args) : [esc(fs)]
  :($([:($f(x::$T, args...) = (Base.@_inline_meta; $f(x.$field, args...)))
       for f in fs]...);
    nothing)
end

"""
    @forward_binary T.x functions...

See `@forward`, but for functions with (first) two arguments of type `T`, e.g. `Base.isequal`.
"""
macro forward_binary(ex, fs)
    @capture(ex, T_.field_) || error("Syntax: @foward_binary T.x f, g, h")
    T = esc(T)
    fs = isexpr(fs, :tuple) ? map(esc, fs.args) : [esc(fs)]
    :($([:($f(x::$T, y::$T, args...) = (Base.@_inline_meta; $f(x.$field, y.$field, args...)))
       for f in fs]...);
    nothing)
end

"""
    @forward_binary_preserve_type T.x functions...

See `@forward` and `@forward_binary`, but for functions, that return a result with the same type as the inputs,
e.g. `Base.:(+)`. Works only, if function changes exactly one field! 
Resulting type is inferred using `promote_type`, which might fail in certain cases. Just try not mixing field types.
"""
macro forward_binary_preserve_type(ex, fs)
    @capture(ex, T_.field_) || error("Syntax: @forward_binary_preserve_type T.x f, g, h")
    T = esc(T)
    fs = isexpr(fs, :tuple) ? map(esc, fs.args) : [esc(fs)]
    :(
        $([
            :(
                $f(x::$T, y::$T, args...) = (
                    Base.@_inline_meta; 
                    (x_type, y_type) = (typeof(x.$field), typeof(y.$field));
                    tmp = (promote_type(x_type, y_type) == x_type ? deepcopy(x) : deepcopy(y));
                    tmp.$field = $f(x.$field, y.$field, args...);
                    tmp
                )
            )
            for f in fs
        ]...);
    nothing)
end