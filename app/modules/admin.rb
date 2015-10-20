require 'sinatra/base'

module Sinatra
	module Admin
		module Helpers

		end
		
		def self.registered(app)

			app.register Sinatra::Flash
			app.get '/admin' do
				haml :admin_menu
			end
			app.get '/admin/messages_config' do
				protected_admin!
				if Messages_config.first() == nil
					haml :config_new
				else
					haml :config_edit
				end
			end

			app.post '/admin/messages_config' do
				protected_admin!
				Messages_config.create(params[:sms])
			end

			app.put '/admin/messages_config' do
				protected_admin!
				Messages_config.first().update(params[:sms])
				redirect to ('/admin/messages_config')
			end

			app.get '/admin/users' do
				protected_admin!
				@usuarios = User.all
				haml :users
			end

			app.get '/admin/users/new' do
				protected_admin!
				@usuario = User.new
				haml :user_new 
			end

			app.post '/admin/users/new' do
				protected_admin!
				if params[:user][:password] == params[:verify][:password] 
					user = User.create(params[:user])
					flash['alert alert-success'] = "Usuario creado satisfactoriamente. <button type='button' class='close' data-dismiss='alert' aria-label='Close'><span aria-hidden='true'>&times;</span></button>"
					redirect to ('/admin/users')
				else
					flash['alert alert-danger'] ="La contraseña de confirmación no concuerda. <button type='button' class='close' data-dismiss='alert' aria-label='Close'><span aria-hidden='true'>&times;</span></button>"
					redirect to ('/admin/users/new')
				end

			end
			app.get '/admin/users/:id/edit' do
				protected_admin!
				@usuario = User.get(params[:id])
				haml :user_edit
			end

			app.put '/admin/users/:id/edit' do
				protected_admin!
				if params[:user][:password] == params[:verify][:password] 
					@usuario = User.get(params[:id]).update(params[:user])
					flash['alert alert-success'] = "Usuario editado satisfactoriamente. <button type='button' class='close' data-dismiss='alert' aria-label='Close'><span aria-hidden='true'>&times;</span></button>"
					redirect to ('/admin/users')
				else
					flash['alert alert-danger'] ="La contraseña de confirmación no concuerda. <button type='button' class='close' data-dismiss='alert' aria-label='Close'><span aria-hidden='true'>&times;</span></button>"					
					redirect to ("/admin/users/#{user.id}/edit/")
				end
			end
			app.get '/admin/users/:id/cobradores' do
				@usuario = User.get(params[:id])
				@cobradores = Cobradore.all
				haml :cobradores
			end
			app.put '/admin/users/:id/cobradores' do
				@user = User.get(params[:id])
				params.each do |key, value|
					@user.cobradores << Cobradore.get(key)
					@user.save
				end
				flash['alert alert-success'] = "Los cobradores han sido añadidos satisfactoriamente al usuario"
				redirect to ('/admin/users') 
			end
			
		end
	end
	register Admin
end