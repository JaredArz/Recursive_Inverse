
include("./mtj.jl")

dev = MTJ_Types.SHE_MTJ(1)
MTJ_Types.set_dev!(dev, Ms=1.0)
display(typeof(dev.Ki))
display(dev)
