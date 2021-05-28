using Pkg

Pkg.add("Cairo")
Pkg.add("DataFrames")
Pkg.add("SQLite")
Pkg.add("Gadfly")
Pkg.add("Fontconfig")
Pkg.add("Tables")

using SQLite
using DataFrames
using SQLite
using Gadfly
using Cairo
using Fontconfig
using Tables

db = SQLite.DB(pwd()*"/"*ARGS[1])

data = DBInterface.execute(db, "SELECT * FROM BabyNames WHERE BabyNames.name = '$(ARGS[2])' COLLATE NOCASE AND BabyNames.sex = '$(ARGS[3])'COLLATE NOCASE ORDER BY BabyNames.year ASC") |> DataFrame

xticks = [minimum(data.year):5:maximum(data.year);]
yticks = [minimum(data.num):maximum(data.num)/10:maximum(data.num);]
push!(yticks, maximum(data.num))
push!(xticks, maximum(data.year))

Gadfly.push_theme(:dark)
p = plot(data, x=:year, y=:num, Guide.xlabel("Time in Years"), Guide.ylabel("Number Used"), Guide.title("Name Popularity: $(ARGS[2]) - $(ARGS[3])"), Guide.xticks(ticks=xticks), Guide.yticks(ticks=yticks), Geom.line)
img = PNG("names.png", 35cm, 14cm)
draw(img, p)