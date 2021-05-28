using Pkg

Pkg.add("DataFrames")
Pkg.add("SQLite")
Pkg.add("ZipFile")
Pkg.add("CSV")
Pkg.add("Tables")

using DataFrames
using ZipFile
using SQLite
using CSV
using Tables

db = SQLite.DB(pwd()*"/"*ARGS[2])
DBInterface.execute(db, "CREATE TABLE IF NOT EXISTS BabyNames(year INTEGER, name TEXT, sex TEXT, num INTEGER)")

r = ZipFile.Reader(pwd()*"/"*ARGS[1])

year = String[]
name = String[]
sex = String[]
num = Int[]

for i in r.files
    if(i.name[1:3] == "yob")
        file = CSV.File(i; header=["name", "sex", "num"], types=[String, String, Int])
        for row in file
            push!(year, i.name[4:7])
            push!(name, row.name)
            push!(sex, row.sex)
            push!(num, row.num)

            # First attempt - very slow and very sad :(
            # SQLite.execute(db,"INSERT INTO BabyNames(year,name,sex,num) VALUES ($(i.name[4:7]),'$(row.name)','$(row.sex)',$(row.num))")
        end
    end
end

arr = [year name sex num]
df = DataFrame(arr)
rename!(df, :x1 => :year, :x2 => :name, :x3 => :sex, :x4 => :num)

SQLite.load!(df, db, "BabyNames")

close(r)
close(db)

# Remove duplicates if needed
# SQLite.removeduplicates!(db, "BabyNames", ["year", "name", "sex", "num"])
