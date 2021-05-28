using Pkg

Pkg.add("DataFrames")
Pkg.add("SQLite")
Pkg.add("LinearAlgebra")

using SQLite
using DataFrames
using LinearAlgebra

db = SQLite.DB(pwd()*"/names.db");

df = DBInterface.execute(db, "SELECT * FROM BabyNames") |> DataFrame;

gd = groupby(df, [:sex]);

Ny = nrow(unique(df, 1));

uniqueG = unique(gd[1],2);
Ng = nrow(uniqueG);

uniqueB = unique(gd[2],2);
Nb = nrow(uniqueB);

g_to_i = Dict{String, Integer}(string(uniqueG[i,2]) => i for i = 1:1:Ng);
i_to_g = Dict{Integer, String}(value => key for (key, value) in g_to_i);

b_to_i = Dict{String, Integer}(string(uniqueB[i,2]) => i for i = 1:1:Nb);
i_to_b = Dict{Integer, String}(value => key for (key, value) in b_to_i);

Fg = zeros(Float32, Ng, Ny);
Fb = zeros(Float32, Nb, Ny);

for i in eachrow(df)
    if(i[3] == "F")
        Fg[g_to_i[string(i[2])],i[1] - 1879] = i[4];
    else
        Fb[b_to_i[string(i[2])],i[1] - 1879] = i[4];
    end
end

Ty = zeros(Float32, 1, Ny);

for i = 1:1:Ny
    Ty[i] = sum(Fg[:,i]) + sum(Fb[:,i]);
end

Pg = zeros(Float32, Ng, Ny);
Pb = zeros(Float32, Nb, Ny);

for i = 1:1:Ny
    Pg[:,i] = Fg[:,i]/Ty[i];
    Pb[:,i] = Fb[:,i]/Ty[i];
end

Qg = zeros(Float32, Ng, Ny);
Qb = zeros(Float32, Nb, Ny);

for i = 1:1:Ng
    Qg[i,:] = normalize(Pg[i,:]);
end
for i = 1:1:Nb
    Qb[i,:] = normalize(Pb[i,:]);
end

global viewg = [];
global viewb = [];

for i = 1:6833:61498
    if(i == 61498)
        push!(viewg, @view Qg[i:i+6834,:]);

    else
        push!(viewg, @view Qg[i:i+6832,:]);
    end
end

for i = 1:4205:37846
    if(i == 37846)
        push!(viewb, @view Qb[i:i+4208,:]);
    else
        push!(viewb, @view Qb[i:i+4204,:]);
    end
end

#= 
Testing for boundries
        print(i,":", i+6834, "\n")
        print(size(@view Qg[i:i+6834,:]),"\n")

        print(i,":", i+6832, "\n")
        print(size(@view Qg[i:i+6832,:]),"\n")
        --------------------------------------
        print(i,":", i+4208, "\n")
        print(size(@view Qb[i:i+4208,:]),"\n")

        print(i,":", i+4204, "\n")
        print(size(@view Qb[i:i+4204,:]),"\n")
=#

global hold = [];
global max_cosine = 0;
global girl = "";
global boy = "";
l = ReentrantLock()

for i = 1:10
Threads.@threads for j = 1:10
        temp_transpose = viewg[i]*transpose(viewb[j])
        temp_max = maximum(temp_transpose)

        # To construct matrix from the 100 parts
        #=
        #lock need to make sure hold isn't written at the same time
        lock(l)
        try
            push!(hold, temp_transpose)
        finally
            unlock(l)
        end
        =#
        
        if(max_cosine < temp_max)
            global max_cosine = temp_max
            found = findall(x->x==temp_max, temp_transpose);
            #print(found[1,1] ,"\n")
            if(i == 10)
                global girl = i_to_g[found[1,1][1]+(6833*(i-1))+2]
                global boy = i_to_b[found[1,1][2]+(4205*(j-1))+4]   
            else
                global girl = i_to_g[found[1,1][1]+6833*(i-1)]
                global boy = i_to_b[found[1,1][2]+4205*(j-1)]  
            end
        end
    end
end

print("Boy and girl pair: (", boy, ", " , girl,")")






