require 'sinatra'
require 'haml'
require 'sqlite3'

db = SQLite3::Database.new "data/comics.db"

pubs_select = 'select name from publishers order by name ASC'
titleselect = db.prepare('select issue,notes from comics where title is ?')
titles_by_publisher = 'select distinct comics.title from comics inner join publishers on comics.publisher=publishers.id where publishers.name is ? order by comics.title ASC'


get '/' do
  "Hello World!"
end


# Display the publishers in the database
get '/publishers' do
  @publishers = db.execute(pubs_select)
  haml :publisher_list 
end


# Display all the titles in the database by the given publisher
get '/publisher/:name' do |name|
  @titles = db.execute(titles_by_publisher, name)
  haml :titlesbypub
end


# Display all the titles in the database
get '/titles' do
  # Show a clickable list of all titles that are in the database
  @titles = db.execute('select distinct title from comics order by title ASC')
  haml :title_list
end


# Display all the issues in the database of a given title
get '/title/:name' do |name|
  rows = titleselect.execute!(name)
  @titles = rows.sort { |x,y| x[0].to_i <=> y[0].to_i }
  
  haml :titles
end


# Display specific infomation about a given title and issue number
get '/title/:name/:issuenumber' do |name, issuenumber|
  @issue = db.execute('select * from comics where title is ? and issue is ?', name, issuenumber)
  haml :issue
end


# Display the form for adding a publisher
get '/addPublisher' do
  haml :add_publisher_form
end


# Form action for adding a publisher
post '/addPublisher' do
  # Check to make sure it doesn't already exist
  rows = db.execute('select id from publishers where name is ?', params[:name])

  if (rows.empty?)
    # No rows were returned, so the publisher doesn't already exist
    db.execute('insert into publishers (name) values (?)', params[:name])
  else
    haml "%h2 A publisher named #{params[:name]} already exists"
  end
end


# Display the form for adding an issue
get '/addIssue' do
  @publishers = db.execute('select id,name from publishers order by name ASC')
  haml :add_issue_form
end


# Form action for adding an issue
post '/addIssue' do
  "Title: #{params[:name]} Issue: #{params[:issuenumber]} Publisher ID:#{params[:publisherid]} "
end