get '/' do
	protected!
	redirect to ('/home')
end

get '/home' do 
	protected!
	@records = Record.all(:limit => 3, :order => :fecha.desc)
	haml :message_form
end

get '/message' do
	protected!
	@records = Record.all(:limit =>  3, :order => :fecha.desc)
	haml :message_form
end

post '/customers/ajax_customers_selectable_list' do
	protected!
	@customers = Pedido.pendientes(params, session)
	haml :ajax_customers_selectable_list, :layout => (request.xhr? ? false : :layout)
end

post '/ajax_message' do
	@text = File.open('masivo.txt', 'w+')
	datos = JSON.parse(request.body.read)
	#Thread.new do
		record = Record.new
		record.attributes = {:fecha => Time.now, :mensaje => datos['mensaje']}
		datos['lista'].each do |cliente|
			@text.puts cliente['telefono'] 
			transformed_text = datos['mensaje'].gsub('(Nombre)', cliente['nombre']).gsub('(Apellido)', cliente['apellido'])
			SMS.new.send_sms(cliente['telefono'], transformed_text)
			record.clientes << Cliente.get(cliente['cedula'])
		end
		record.user = User.get(session[:id])
		record.save
	#end
	@text.rewind
end

get '/records' do
	@records = Record.all
	haml :records
end

