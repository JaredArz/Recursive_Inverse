using Plots
using Printf
using LinearAlgebra:inv,norm,Tridiagonal,Diagonal
using SparseArrays
using BenchmarkTools

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

cutoff = 4
println("Estimating complexity...\n")
n_arr = zeros(0)
lib_t = zeros(0)
rec_t = zeros(0)


let n,lt,rt = 0
    for e in 0:3
        for d in [4,8]
            # repeat btime (compilation)
            for _ in [0,0]
                n = d*10^e
                lt  = @belapsed inv(M) setup=(M = Matrix(sparse(Tridiagonal(ones(Float64,$n,$n))) + Diagonal(0.001*im*ones($n))))
                rt  = @belapsed recInv(M, cutoff) setup=(M = (sparse(Tridiagonal(ones(Float64,$n,$n))) + Diagonal(0.001*im*ones($n))))
                #rt = @belapsed recInv(M, cutoff) setup=(M= sparse(Tridiagonal(ones(Float64,$n,$n))))
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
