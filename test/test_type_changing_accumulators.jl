module TestTypeChangingAccumulators

using CUDA
using Folds
using FoldsCUDA
using Test
using Transducers

missing_if_odd(x) = isodd(x) ? missing : x

@testset "sum" begin
    @test Folds.sum(missing_if_odd, 0:2:2^10, CUDAEx()) == sum(0:2:2^10)
    @test Folds.sum(missing_if_odd, 0:2:2^20, CUDAEx()) == sum(0:2:2^20)
    @test Folds.sum(missing_if_odd, 0:2^10, CUDAEx()) === missing
    @test Folds.sum(missing_if_odd, 0:2^20, CUDAEx()) === missing
end

partition_length_maximum(xs, ex = PreferParallel()) = Transducers.fold(
    max,
    xs |> ReducePartitionBy(identity, Map(_ -> 1)'(+), 0),
    ex;
    init = typemin(Int),
)

@testset "partition_length_maximum" begin
    @testset "2^$e" for e in [10, 15]
        xs = CUDA.rand(Bool, 2^e)
        @test partition_length_maximum(xs) == partition_length_maximum(collect(xs))
    end
    @testset "2^$e" for e in [20, 25]
        xs = CUDA.rand(Bool, 2^e)
        @test_broken partition_length_maximum(xs) == partition_length_maximum(collect(xs))
    end
end

end  # module
