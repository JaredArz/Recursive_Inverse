
include("./mtj.jl")


dev = MTJ_Types.SHE_MTJ()
MTJ_Types.set_dev!(dev, Ms=7.0, Ki=1.0)
display(dev)
display(dev.Ki.x)
