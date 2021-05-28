using Pkg

Pkg.add("Cairo")
Pkg.add("DataFrames")
Pkg.add("SQLite")
Pkg.add("Gadfly")
Pkg.add("Fontconfig")
Pkg.add("Tables")

using SQLite
using DataFrames
using Gadfly
using Cairo
using Fontconfig

db = SQLite.DB(pwd()*"/"*ARGS[1])

data = DBInterface.execute(db, "SELECT * FROM BabyNames WHERE BabyNames.name = '$(ARGS[2])' COLLATE NOCASE AND BabyNames.sex = '$(ARGS[3])'COLLATE NOCASE ORDER BY BabyNames.year ASC") |> DataFrame

# Ticks start at the min and end at the max for the repective values
xticks = [minimum(data.year):5:maximum(data.year);]
yticks = [minimum(data.num):maximum(data.num)/10:maximum(data.num);]

# xticks = [1880:5:2019;] # If you want the whole plot with the empty years

# push!(xticks, maximum(data.year)) # Adds 2019 to the ticks but may cause overlap on 2018
push!(yticks, maximum(data.num)) # Adds the peak popularity of the name

Gadfly.push_theme(:dark)
p = plot(data, x=:year, y=:num, Guide.xlabel("Time in Years"), Guide.ylabel("Number Used"), Guide.title("Name Popularity: $(ARGS[2]) - $(ARGS[3])"), Guide.xticks(ticks=xticks), Guide.yticks(ticks=yticks), Geom.line)
img = PNG("names.png", 35cm, 14cm)
draw(img, p)