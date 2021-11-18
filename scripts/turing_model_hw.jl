using Turing, StatsPlots, Distributions

@model utility(df) = begin
    β = 1

    x = 10 - j/10
    p = 10 - j/2
    ξ = j/5

    ϵ ~ GeneralizedExtremeValue(0,1,0)
    α ~ LogNormal(0.3, sqrt(0.1))
    
    u = β*x - α*p + ξ + ϵ

end

leftjoin(df, choices, on = [:i, :j, :ϵ, :u, :x, :p, :ξ])

test = DataFrame(a = repeat(rand(LogNormal(0.3, 1/0.1), 1), 1000))



X = Matrix(select(df, Not(:chosen)))
y = Matrix()