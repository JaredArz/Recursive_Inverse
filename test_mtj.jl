
include("./mtj.jl")

dev = MTJ_Types.SHE_MTJ()
MTJ_Types.set_dev!(dev, Ki=1.0)
display(dev)
