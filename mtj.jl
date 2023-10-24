module MTJ_Types

export SHE_MTJ, sample, set_dev

abstract type MTJ end
#Base.@kwdef
mutable struct SHE_MTJ <: MTJ
    Ki::Float64
    Rp::Float64
    J_SHE::Float64
    Ms::Float64
    theta::Float64
    phi::Float64
    Theta::Float64
    SHE_MTJ() = new()
end

function set_dev!(MTJ::MTJ, ;kwargs...)
    for (key, value) in kwargs
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
       print(io,i,": ",getfield(MTJ,i),"\n")
    end
end
end
