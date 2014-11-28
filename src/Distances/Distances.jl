#===============================================================================
                    Distance computing utilities
===============================================================================#

export distance, distance_array, distance3d, minimal_image

# Refine a vector using the minimal image convention
@inline minimal_image(vect::AbstractVector, box::SimBox{InfiniteBox}) = vect

@inline function minimal_image(vect::AbstractVector, box::SimBox{OrthorombicBox})
    return [
        vect[1] - round(vect[1]/box[1])*box[1],
        vect[2] - round(vect[2]/box[2])*box[2],
        vect[3] - round(vect[3]/box[3])*box[3]
    ]
end

@inline function minimal_image(vect::AbstractVector, box::SimBox{TriclinicBox})
    u = cart2fract(vect, box)
    return fract2cart([u[1] - round(u[1]),
                       u[2] - round(u[2]),
                       u[3] - round(u[3])],
                      box)
end

@inline function cart2fract(vect::AbstractVector, box::SimBox)
    const z = vect[3]/box[6]
    const y = (vect[2] - z*box[5])/box[3]
    const x = (vect[1] - z*box[4] - y * box[2]) / box[1]

    return [x, y, z]
end

@inline function fract2cart(vect::AbstractVector, box::SimBox)
    return [
        vect[1]*box[1] + vect[2]*box[2] + vect[3]*box[4],
        vect[2]*box[3] + vect[3]*box[5],
        vect[3]*box[6]
    ]
end

# Compute the distance between to particles
@inline function distance(ref::Frame, conf::Frame, i::Integer, j::Integer)
    return norm(minimal_image(ref.positions[j] - conf.positions[i], ref.box))
end

@inline function distance(ref::Frame, i::Integer, j::Integer)
    return distance(ref, ref, i, j)
end

# Compute the vectorial distance between to particles
@inline function distance3d(ref::Frame, conf::Frame, i::Integer, j::Integer)
    return minimal_image(ref.positions[j] - conf.positions[i], ref.box)
end

@inline function distance3d(ref::Frame, i::Integer, j::Integer)
    return distance3d(ref, ref, i, j)
end

function distance_array(ref::Frame, result = nothing)
    return distance_array(ref, ref, result)
end

function distance_array(ref::Frame, conf::Frame, result = nothing)
    cols = length(ref.positions)
    rows = length(conf.positions)
    # Checking the pre-allocated array
    if result == nothing
        result = Array(Float64, cols, rows)
    else
        if !((size(result, 1) == cols) && (size(result, 2) == rows))
            warning("Wrong pre-allocated array shape. Is $(size(result)), " *
                    "should be ($(cols),$(rows))\n" *
                    "Resizing ...")
            resize!(result, (cols, rows))
        end
    end
    compute_distance_array!(result, ref, conf, rows, cols)
    return result
end

function compute_distance_array!(result, ref, conf, nrows, ncols)
    @inbounds for j=1:nrows, i=1:ncols
       result[i,j] = distance(ref, conf, i, j)
    end
end
