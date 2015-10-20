require 'sinatra'
require 'rubygems'
require 'haml'
require 'pony'
require 'rufus-scheduler'
require 'dm-core'
require 'dm-migrations'
require 'savon'
require 'sinatra/flash'
require 'json'

Dir["./app/**/*.rb"].each do |file|
    require file
end

configure do 
	DataMapper.setup(:default, 'mysql://pitwa:uy612myrrym216yu@190.204.10.34/moravi')
end

#configure :development do
 #=> Standart Configuration SQLite
#  DataMapper.setup(:default, (ENV["DATABASE_URL"] || "sqlite3:///#{Dir.pwd}/development.sqlite3"))
#  DataMapper.auto_upgrade!
#end

scheduler = Rufus::Scheduler.new

scheduler.every '1h' do
	cuotas = Cuota.all
	cuotas.each do |cuota|
		cuota.fecha_de_vencimiento = DateTime.parse((cuota.fecha_de_vencimiento + 1).to_s)
		cuota.save
	end
end


set :views, Proc.new { File.join(root, "app/views") }