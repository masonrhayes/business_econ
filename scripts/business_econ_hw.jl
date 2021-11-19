using Distributions, StatsPlots, DataFrames, StatsBase, FreqTables, VegaLite, Pluto

I = 10000
J = 8
β = 1
α = 1

df = DataFrame(
    i = repeat(1:I, J+1), 
    j = repeat(0:J, I),
    ϵ = repeat(zeros(Float64,1), 90000),
    u = repeat(zeros(Float64,1), 90000),
    chosen = repeat(zeros(Float64, 1), 90000))


function price(j)
    p = 10 .- j/2
    return p
end


function xi(j)
    ξ = j/5
    return ξ
end

function value(j)
    x = 10 .- j/10
    return x
end


# Transform DF by adding price, x, and ξ
transform!(df, :j => price => :p)
transform!(df, :j => xi => :ξ)
transform!(df, :j => value => :x)

# Epsilon is col 3
for i in 1:90000
    df[i,3] = rand(GeneralizedExtremeValue(0,1,0))
end

# u is col 4
for i in 1:90000
    df[i,4] = β * df[i,8] - α * df[i,6] + df[i,7] + df[i,3]
end


describe(df)

df

function indicator(x,y)
    if x .≥ y
        dummy = 1
    else 
        dummy = 0
    end

    return dummy
end


# leftjoin(df, choices, on = [:i, :j, :ϵ, :u, :x, :p, :ξ])

transform!(groupby(df, :i), :u => maximum => :u_maximum)

for i in 1:90000
    df[i,5] = indicator(df[i,4], df[i,9])
end

# What do most people choose?

freqtable(df, :chosen, :j)

# Q1



# Q2 

params = DataFrame(
    i = repeat(1:I, J+1), 
    j = repeat(0:J, I),
    α = repeat(zeros(Float64, 1), 90000),
    new_u = repeat(zeros(Float64, 1), 90000)
)

for i in 1:90000
    params[i,3] = rand(LogNormal(0.3, sqrt(0.10)))
end

params

q2_df = select(leftjoin(df, params, on = [:i, :j]), Not([:u, :u_maximum]))

for i in 1:90000
    q2_df[i, 9] = β * q2_df[i, 7] - q2_df[i, 8] * q2_df[i, 5] + q2_df[i, 6] + q2_df[i, 3]
end

## Find individual's max utility
transform!(groupby(q2_df, :i), :new_u => maximum => :new_u_maximum)

for i in 1:90000
    q2_df[i,4] = indicator(q2_df[i,9], q2_df[i,10])
end

println("Freq Table with α = 1")
freqtable(df, :chosen, :j)

println("Freq Table with α ~ LogNormal(0.3, sqrt(0.10)")
freqtable(q2_df, :chosen, :j)

rename!(df, :chosen => :chosen1)
rename!(q2_df, :chosen => :chosen2)

q2_df[!, :α] = convert.(Float64, q2_df[:, :α])
q2_df[!, :new_u] = convert.(Float64, q2_df[:, :new_u])
# Q2 

# Combine df and q2_df, group by j and find the total number of customers who purchase
combined_data = combine(groupby(leftjoin(df, select(q2_df, :i, :j, :chosen2, :α, :new_u, :new_u_maximum), on = [:i, :j]), :j), :chosen1 => sum, :chosen2 => sum, :α => mean, :u => mean, :u_maximum => mean, :new_u => mean, :new_u_maximum => mean)


# Calculate market shares (note the market is covered in both scenarios)
transform!(combined_data, :chosen1_sum => (x -> x / 100) => :market_share1)
transform!(combined_data, :chosen2_sum => (x -> x / 100) => :market_share2)


# double checking that market is covered
freqtable(q2_df, :chosen2, :new_u)

sort(q2_df, order(:new_u_max))


# Q3: Consumer Surplus

function cs(max_utility, α=1)
    surplus = max_utility ./ α

    return surplus
end


transform!(combined_data, [:u_maximum_mean] => cs => :surplus1)
transform!(combined_data, [:new_u_maximum_mean, :α_mean] => cs => :surplus2)

histogram(q2_df.α, xaxis = "α", label = "Simulated α", normalize = true)
# Fit α to a Log Normal Distribution
fitted_α = fit(LogNormal, q2_df.α)
distr_α = Distributions.params(fitted_α)
plot!(LogNormal(distr_α[1], distr_α[2]), label = "True Log Normal Density")


# Do the same for utility
fitted_new_u_max = fit(Normal, q2_df.new_u_maximum)
distr_new_u_max = Distributions.params(fitted_new_u_max)



histogram(q2_df.new_u, xaxis = ("Simulated Utility"), xlims = (-20,20), label = "All Values") 


histogram!(q2_df.new_u_maximum, label = "Of Purchases Decisions") 
ylabel!("Count")


