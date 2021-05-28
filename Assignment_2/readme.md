# Prepare.jl
This script takes in two command line arguments, the zip file name and the name of the database to create. Once the database
file is created, a table is added to the database called BabyNames. The zip file is opened and a database transaction is started
with a prepared statement to insert items into the newly created table. The files are looped through adding every row into the 
table with the year included from the filename. Finally, the transaction is committed and the connection to file and database
are closed.

# Plot.jl
This script takes in three command line arguments, the database file name, the name wanted to search, and the corresponding gender to
the name. The script first initializes a connection to the database file performs a select where the name and gender match exactly
(not case sensitive). Once the select is finished, the data is piped into a dataframe which is then used to produce a plot over time of the 
frequency of the name.

The plot begins at the earliest occurrence of the name and ends at the last occurrence.