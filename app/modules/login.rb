require 'sinatra/base'

module Sinatra
	module Auth
		module Helpers
			def authorized?
				session[:started]
			end
			def authorized_admin?
				session[:admin]
			end
			def protected_admin!
				halt 401, haml(:home) unless authorized_admin?
			end
			def protected!
				halt 401, haml(:login, :layout => :layout_login) unless authorized?
			end
			def login
				user = User.authenticate(params[:login])
				if user == false
					redirect to('/login')
				else
					session[:started] = true
					session[:user] = user.nick
					session[:admin] = true if user.admin?
					session[:id] = user.id
					#create a array of cobrradores
					cobradores = Array.new 
					user.cobradores.each do |cobrador|
						cobradores << cobrador.id
					end
					session[:cobradores] = cobradores
				end
			end
		end

		def self.registered(app)
			app.helpers Helpers

			app.enable :sessions

			app.get '/login' do
				@title = "Iniciar sesión"
				# create admin if this does not exist
				if User.first == nil
					User.create(:nick => "admin", :password => "admin", :admin => true)
				end
				haml :login, :layout => :layout_login
			end

			app.post '/login' do
				login
				redirect to ('/home')
			end
			app.get '/logout' do
				session.clear
				redirect to('/login')
			end
		end
	end
	register Auth
end