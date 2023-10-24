module MTJ_Types

    export SHE_MTJ, sample, set_dev

    struct _DeviceParam <: AbstractFloat
        x::Float64
    end
    struct _Noisy <: _DeviceParam
        x::Float64
    end

    # _NoisyParam = Union{_Noisy, _DeviceParam}

    abstract type _MTJ end
    abstract type Param <: Abstract end

    mutable struct SHE_MTJ <: _MTJ
        Ki    :: _Noisy
        Ms    :: _DeviceParam
        J_SHE :: Float64

        SHE_MTJ() = new(1.0, 1.0, 1.0)
    end


    add_noise(x::Float64) = x*21341.0 
    function _update_dev!(MTJ::_MTJ, key::Symbol, value::Float64)
        display(key)
        display(getfield(MTJ,key))
        if isa( getfield(MTJ,key), _Noisy)
            return setfield!(MTJ, key, _Noisy(add_noise(value)))
        elseif isa( getfield(MTJ,key), _DeviceParam)
                return setfield!(MTJ, key, _DeviceParam(value))
        else
            return setfield!(MTJ, key, value)
        end
    end

    function set_dev!(MTJ::_MTJ, ;kwargs...)
        for (key, value) in kwargs
            _update_dev!(MTJ, key, value)
        end
    end

    function sample(MTJ::SHE_MTJ)
        #LLG
    end

    #function sample(MTJ::STT_MTJ)
    #    #LLG
    #end

    function Base.show(io::IO, MTJ::_MTJ)
        # type inference cannot occur here
        print(io, "Device Parameters:\n")
        for i in fieldnames(typeof(MTJ))
            if isa(getfield(MTJ,i), _DeviceParam)
                print(io,i,": ", getfield(MTJ,i).x,"\n")
            end
        end
    end
end
