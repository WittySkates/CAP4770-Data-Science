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

SQLite.transaction(db)
stmt = DBInterface.prepare(db, "INSERT INTO BabyNames(year,name,sex,num) VALUES(?1, ?2, ?3, ?4)")
for i in r.files
    if(i.name[1:3] == "yob")
        file = CSV.File(i; header=["name", "sex", "num"], types=[String, String, Int])
        for row in file
            DBInterface.execute(stmt, (i.name[4:7], row.name, row.sex, row.num))
        end
    end
end
SQLite.commit(db)

close(r)
close(db)

# Remove duplicates if needed
# SQLite.removeduplicates!(db, "BabyNames", ["year", "name", "sex", "num"])
