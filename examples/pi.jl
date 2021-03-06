#=
Copyright (c) 2015, Intel Corporation
All rights reserved.

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are met:
- Redistributions of source code must retain the above copyright notice, 
  this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
THE POSSIBILITY OF SUCH DAMAGE.
=#

using HPAT 
using MPI
using DocOpt

@acc hpat function calcPi(n::Int64)
    x = rand(n) .* 2.0 .- 1.0
    y = rand(n) .* 2.0 .- 1.0
    return 4.0*sum(x.^2 .+ y.^2 .< 1.0)/n
end

function main()
    doc = """pi.jl

Estimate Pi using Monte Carlo method.

Usage:
  pi.jl -h | --help
  pi.jl [--points=<points>]

Options:
  -h --help                  Show this screen.
  --points=<points>  Specify number of generated random points; defaults to 10^7.
"""
    arguments = docopt(doc)

    if (arguments["--points"] != nothing)
        points = parse(Int, arguments["--points"])
    else
        points = 10^7
    end
    rank = MPI.Comm_rank(MPI.COMM_WORLD)
    pes = MPI.Comm_size(MPI.COMM_WORLD)
    
    if rank==0 println("points= ", points) end

    tic()
    calcPi(100)
    if rank==0 println("SELFPRIMED ", toq()) end

    MPI.Barrier(MPI.COMM_WORLD)
    tic()
    pi_val = calcPi(points)
    time = toq()
    if rank==0 println("pi = ", pi_val) end
    if rank==0 println("SELFTIMED ", time) end

end

main()

