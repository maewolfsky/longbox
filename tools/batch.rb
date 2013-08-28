require "sqlite3"
require "CSV"
# A quick and dirty way to create the initial database
#  and load data from csv

# Next steps
#   Take command line arguments for database name and actions


# Take a database and create the tables needed
def initialize_database
  rows = @db.execute <<-SQL
    CREATE TABLE publishers (
      id integer primary key,
      name varchar(30)
    );
  SQL
  # Is there a way to put these in one statement? 
  rows = @db.execute <<-SQL
    CREATE TABLE comics (
      id integer primary key,
      title varchar(40),
      issue varchar(10),
      publisher integer,
      notes varchar(256),
      FOREIGN KEY(publisher) REFERENCES publisher(id) 
    );
    SQL
end


# First pass of adding base publishers to the database
def initialize_publishers
  [ 
    'Marvel',
    'DC',
    'Image',
    'Vertigo',
    'IDW',
    'Valiant',
    'Now'
  ].each do |publisher|
    @db.execute("insert into publishers values ( NULL, ? )", publisher)
  end
end


# Load bulk data about comics from a csv file with the following format
#  Title,Issue,Publisher
def load_data(filename)
  insertstmt = "insert into comics values (NULL, ?, ?, ?, ?)"

  CSV.foreach(filename, headers: true) do |comic|
    # do some lookup thing to get the publisher.id
    rows = @db.execute("select id from publishers where name is ?", comic["Publisher"])
    # The the previous select statement should only return a single value
    @db.execute(insertstmt, comic["Title"], comic["Issue"], rows[0][0], comic["Notes"])
  end
end


# Test to make sure data is in the database
def test
  @db.execute("select * from comics") do |row|
    p row
  end

  @db.execute("select * from publishers") do |row|
    p row
  end 
end


@db = SQLite3::Database.new "../data/comidddcs.db"


# IF database file doesn't exist, create it 
#initialize_database(db)
#initialize_publishers(db)

# Bulk load some data
#load_data(db, "comics.csv")


#test()
