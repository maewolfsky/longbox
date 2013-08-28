require 'sinatra'
require 'haml'
require 'sqlite3'

db = SQLite3::Database.new "comics.db"

pubs_select = 'select name from publishers order by name ASC'
titleselect = db.prepare('select issue,notes from comics where title is ?')
titles_by_publisher = 'select distinct comics.title from comics inner join publishers on comics.publisher=publishers.id where publishers.name is ? order by comics.title ASC'


get '/' do
  "Hello World!"
end


# Done
get '/publishers' do
  @publishers = db.execute(pubs_select)
  haml :publisher_list 
end


# Done
get '/publisher/:name' do |name|
  @titles = db.execute(titles_by_publisher, name)
  haml :titlesbypub
end


# Done
get '/titles' do
  # Show a clickable list of all titles that are in the database
  @titles = db.execute('select distinct title from comics order by title ASC')
  haml :title_list
end



get '/title/:name' do |name|
  rows = titleselect.execute!(name)
  @titles = rows.sort { |x,y| x[0].to_i <=> y[0].to_i }
  
  haml :titles
end


# Needs template
get '/title/:name/:issuenumber' do |name, issuenumber|
  @issue = db.execute('select * from comics where title is ? and issue is ?', name, issuenumber)
  haml :issue
end



get '/addPublisher' do
  haml :add_publisher_form
end

post '/addPublisher' do
  
end



get '/addIssue' do
  @publishers = db.execute('select id,name from publishers order by name ASC')
  haml :add_issue_form
end

post '/addIssue' do
  "Title: #{params[:name]} Issue: #{params[:issuenumber]} Publisher ID:#{params[:publisherid]} "
end