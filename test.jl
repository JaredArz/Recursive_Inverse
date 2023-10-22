using Plots
using LinearAlgebra:inv

function rec_inv(M::Array{Float64, 2}, size_cutoff::Int=32)
    println("\nIN FUNCTION:")
    nx = size(M)[1]
    ny = size(M)[2]

    left_lenx  = 1:div(nx,2)
    upper_leny = 1:div(ny,2)
    right_lenx = div(nx,2)+1:nx
    lower_leny = div(ny,2)+1:ny

    A = M[left_lenx, upper_leny]
    V = M[right_lenx, upper_leny]
    U = M[left_lenx, lower_leny]
    D = M[right_lenx, lower_leny]
    
    B = A - U*inv(D)*V
    M_inv = [ inv(B) -inv(B)*U*inv(D) ; -inv(D)*V*inv(B) inv(D) + inv(D)*V*inv(B)*U*inv(D) ]

    return M_inv
end

M = [ 1.0 2.0 3.0 0.0; 4.0 5.0 6.0 0.0; 0.0 5.0 4.0 3.0; 0.0 2.0 1.0 0.0 ]
cutoff = 4

print("M, "); display(M)
print("\nM inverse (jl), "); display(inv(M))
print("\nM inverse (rec), "); display(rec_inv(M, cutoff))
