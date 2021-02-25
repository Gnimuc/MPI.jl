using MPI

MPI.Init()

@assert MPI.Comm_size(MPI.COMM_WORLD) == 2

function pingpong(T, bufsize, iters)

    buffer = rand(T, bufsize)

    rank = MPI.Comm_rank(MPI.COMM_WORLD)
    tag = 0

    MPI.Barrier(MPI.COMM_WORLD)

    tic = MPI.Wtime()
    for i = 1:iters
        if rank == 0
            MPI.send(buffer, 1, tag, MPI.COMM_WORLD)
            buffer,_ = MPI.recv(1, tag, MPI.COMM_WORLD)
        else
            buffer,_ = MPI.recv(0, tag, MPI.COMM_WORLD)
            MPI.send(buffer, 0, tag, MPI.COMM_WORLD)
        end
    end
    toc = MPI.Wtime()

    avgtime = (toc-tic)/iters
    return avgtime
end

pingpong(Float64, 1, 100)

for k = 0:20
    bufsize = 2^k
    iters = k < 15 ? 10_000 : 1000 
    avgtime = pingpong(Float64, bufsize, iters)
    if MPI.Comm_rank(MPI.COMM_WORLD) == 0
        println(bufsize, ", ", avgtime)
    end
end
