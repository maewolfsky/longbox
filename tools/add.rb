require "sqlite3"

# Add new comics to the database

db = SQLite3::Database.new "comics.db"

insertstmt = "insert into comics values (NULL, ?, ?, ?, ?)"

printf("Title: ")
title = gets.chomp

printf("Issue Number: ")
number = gets.chomp

printf("Publisher: ")
publisher = gets.chomp

printf("Notes: ")
notes = gets.chomp

# Get the specific publisher ID
rows = db.execute("select id from publishers where name is ?", publisher)
# The the previous select statement should only return a single value
db.execute(insertstmt, title, number, rows[0][0], notes)