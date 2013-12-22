require 'sinatra'
require 'haml'
require 'sqlite3'

db = SQLite3::Database.new "data/comics.db"
db.results_as_hash = true  # Make my life easier later if things are added to the schema

allpubs = 'select * from publishers order by name ASC'
titleselect = 'select * from comics where title is ?'
titles_by_publisher = 'select distinct comics.title from comics inner join publishers on comics.publisher=publishers.id where publishers.name is ? order by comics.title ASC'


get '/' do
  haml :index
end


# Display the publishers in the database
get '/publishers' do
  @publishers = db.execute(allpubs)
  haml :publishers 
end


# Display all the titles in the database by the given publisher
get '/publisher/:name' do |name|
  @titles = db.execute(titles_by_publisher, name)
  haml :publisher_name
end


# Display all the titles in the database
get '/titles' do
  # Show a clickable list of all titles that are in the database
  @titles = db.execute('select distinct title from comics order by title ASC')
  haml :titles
end


# Display all the issues in the database of a given title
get '/title/:name' do |name|
  rows = db.execute(titleselect, name)
  @titles = rows.sort { |x,y| x[0].to_i <=> y[0].to_i }
  
  haml :title_name
end


# Display specific infomation about a given title and issue number
get '/title/:name/:issuenumber' do |name, issuenumber|
  @issue = db.execute('select * from comics where title is ? and issue is ?', name, issuenumber)
  haml :title_name_issuenumber
end


# Display the form for adding a publisher
get '/addPublisher' do
  haml :addpublisher
end


# Form action for adding a publisher
post '/addPublisher' do
  # Check to make sure it doesn't already exist
  rows = db.execute('select id from publishers where name is ?', params[:name])

  if (rows.empty?)
    # No rows were returned, so the publisher doesn't already exist
    db.execute('insert into publishers (name) values (?)', params[:name])
    redirect to('/publishers')
  else
    haml "%h2 A publisher named #{params[:name]} already exists"
  end
end


# Display the form for adding an issue
get '/addIssue' do
  @publishers = db.execute(allpubs)
  haml :addissue
end


get '/addIssue/:name' do |name|
  @publishers = db.execute(allpubs)
  haml :addissue
end


# Form action for adding an issue
post '/addIssue' do
  db.execute(
    'insert into comics (title,issue,publisher,notes) values (?,?,?,?)', 
    params[:name], params[:issuenumber], params[:publisherid], params[:notes]
  )
  # Call the /title/:name/:issuenumber on success?  Or just display a message and have a redirect in x seconds to the addIssue page
  redirect to("/title/#{URI.escape(params[:name])}/#{URI.escape(params[:issuenumber])}")
end


# Display form for modifying an issue
get '/modifyIssue/:id' do |id|
  @publishers = db.execute(allpubs)
  @issue = db.execute('select id,title,issue,publisher,notes from comics where id = ?', id)[0]
  haml :modifyissue, :locals => {:issue => @issue[0]}
end


# Form action for modifying an existing issue
post '/modifyIssue' do
  db.execute(
    'update comics set title=?, issue=?, publisher=?, notes=? where id=?',
    params[:title], params[:issuenumber],
    params[:publisherid], params[:notes],
    params[:issueid])
  redirect to("/title/#{URI.escape(params[:title])}/#{URI.escape(params[:issuenumber])}")
end


# Delete the issue identified by id
get '/deleteIssue/:id' do |id|
  db.execute('delete from comics where id=?', id)
  redirect to("/titles")
end
