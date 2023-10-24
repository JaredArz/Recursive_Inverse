module MTJ_Types

    export SHE_MTJ, sample, set_dev

    abstract type MTJ end
    abstract type noisy end
    abstract type device_param end

    struct noisy  end
    struct device_param end

    mutable struct SHE_MTJ <: MTJ
        Ki    :: Union{Float64, noisy, device_param}
        Ms    :: Union{Float64, device_param}
        J_SHE :: Float64

        theta :: Float64 
        phi   :: Float64

        noise :: Float64
        SHE_MTJ(device_var_flag) = (device_var_flag == 1 ? new(5e11,1e6,π/10,0,0.05) :
                                                           new(5e11,1e6,π/10,0,1))
    end

    add_noise(x::Union{Float64,noisy}, n::Float64) = n*x 
    add_noise(x::Float64, n::Float64) = x

    function set_dev!(MTJ::MTJ, ;kwargs...)
        for (key, value) in kwargs
            value = add_noise(value, MTJ.noise)
            setfield!(MTJ, key, value)
        end
    end

    function sample(MTJ::SHE_MTJ)
        #LLG
    end

    #function sample(MTJ::STT_MTJ)
    #    #LLG
    #end

    function Base.show(io::IO, MTJ::MTJ)
        # type inference cannot occur here
        print(io, "Device Parameters:\n")
        for i in fieldnames(typeof(MTJ))
            if typeof(getfield(MTJ,i)) <: device_param
                print(io,i,": ", getfield(MTJ,i),"\n")
            end
        end
    end
end
