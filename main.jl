using Plots
using Printf
using LinearAlgebra:inv,norm,Tridiagonal,Diagonal
using SparseArrays
using BenchmarkTools




function rec_inv(M::Array{Float64, 2}, size_cutoff::Int=32)
    nx = size(M)[1]
    ny = size(M)[2]

    # square matrix, either nx or ny works to check for base case
    if nx <= size_cutoff
        # library inverse, applicable for the base case
        return inv(M)
    end

    # block dimensions
    left_lenx  = 1:div(nx,2)
    upper_leny = 1:div(ny,2)
    right_lenx = div(nx,2)+1:nx
    lower_leny = div(ny,2)+1:ny

    A = M[left_lenx, upper_leny]
    V = M[right_lenx, upper_leny]
    U = M[left_lenx, lower_leny]
    D = M[right_lenx, lower_leny]

    # recursive calls to invert increasingly smaller --
    # sub matrices
    D_inv = rec_inv(D)
    B = A - U*D_inv*V
    B_inv = rec_inv(B)

    M_inv = [ B_inv -B_inv*U*D_inv ; -D_inv*V*B_inv D_inv + D_inv*V*B_inv*U*D_inv ]

    return M_inv
end


exactInv(A) = inv(Array(A))
# using Woodbury matrix recursion identity
function recInv(M::Union{SparseMatrixCSC, SubArray}, sizecutoff::Int=64)
    nx = size(M)[2]
    ny = size(M)[1]
    if (nx <= sizecutoff || ny <= sizecutoff)
        return sparse(exactInv(M))
    else
        hxu = Int(round(nx/2)) + 1; hyu = Int(round(ny/2)) + 1
        hxl = hxu -1; hyl = hyu -1
        A = M[1:hyl,1:hxl];  U = M[1:hyl,hxu:nx];
        V = M[hyu:ny,1:hxl]; C = M[hyu:ny,hxu:nx];
        Cinv = recInv(C,sizecutoff)
        Γ = Cinv*V; Δ = U*Cinv
        Σ = recInv(A .- Δ*V,sizecutoff)
        Minv = [Σ          -Σ*Δ;
                -Γ*Σ   Cinv .+ Γ*Σ*Δ]
        return Minv
    end
end


#println("Computing error...")
#let x = 0
#    n = 100
#    sum_err = 0.0
#    while x < 100
#        M = rand(Float64,n,n)
#        lib_Minv = inv(M)
#        rec_Minv = rec_inv(M, cutoff)
#        sum_err += (norm(lib_Minv) - norm(rec_Minv))/norm(lib_Minv)
#        x+=1
#    end
#    @printf "Relative error averaged across %d iterations: %e\n" x sum_err/Float64(x)
#end

cutoff = 4
println("Estimating complexity...\n")
n_arr = zeros(0)
lib_t = zeros(0)
rec_t = zeros(0)
println("Example Matrix: ")
M=sparse(Tridiagonal(ones(Float64,4,4)))
display(M)

#let n,lt,rt = 0
#    for e in 0:3
#        for d in [4,8]
#            # repeat btime (compilation)
#            for _ in [0,0]
#                n = d*10^e
#                lt  = @belapsed inv(M) setup=(M = Matrix(sparse(Tridiagonal(ones(Float64,$n,$n))) + Diagonal(0.001*im*ones($n))))
#                rt  = @belapsed recInv(M, cutoff) setup=(M = (sparse(Tridiagonal(ones(Float64,$n,$n))) + Diagonal(0.001*im*ones($n))))
#                #rt = @belapsed recInv(M, cutoff) setup=(M= sparse(Tridiagonal(ones(Float64,$n,$n))))
#            end
#            append!(n_arr, n)
#            append!(lib_t, lt)
#            append!(rec_t, rt)
#        end
#    e+=1
#    end
#end
let n,lt,rt = 0
    for e in 0:3
        for d in [4,8]
            # repeat btime (compilation)
            for _ in [0,0]
                n = d*10^e + 1
                lt = @belapsed inv(M) setup=(M=rand(Float64,$n,$n))
                rt = @belapsed rec_inv(M, cutoff) setup=(M=rand(Float64,$n,$n))
            end
            append!(n_arr, n)
            append!(lib_t, lt)
            append!(rec_t, rt)
        end
    e+=1
    end
end

plot(n_arr, [lib_t rec_t], title="Rough Time Complexity",
     label=["Library inverse" "Recursive solution"], yaxis=:log, linewidth=3)
savefig("complexity2.png")
