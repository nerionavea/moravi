class User
	include DataMapper::Resource
	property :id, Serial
	property :nombre, String
	property :apellido, String
	property :nick, String
	property :password, String
	property :active, Boolean, :default => true
	property :admin, Boolean
	has n, :records
	has n, :cobradores

	def self.authenticate(login)
    user = User.first(:nick => login[:nick])
    if user == nil
   		false
    else
    	user.password == login[:password] ? user : false
    end
    end

end

class Cobradore
	include	DataMapper::Resource
	property :id, String, :key => true, :length => 10
	property :nombre, String, :length => 40
	has n, :pedidos
	belongs_to :user, :required => false
end

class Pedido
	include DataMapper::Resource
	property :id, String, :length => 15, :key => true
	property :nota_pedido, Text
	belongs_to :cliente
	belongs_to :cobradore
	
	has n, :cuotas

	Linea = Struct.new(:cedula, :nombre, :apellido, :telefono, :num_pedido, :cuotas, :ultimo_vencimiento, :bs_cuota, :saldo_cuota, :cobrador)
	def self.pendientes params, session
		@pedidos = Pedido.buscar_por_fecha(params)
		tabla = Array.new	
		@pedidos.each do |pedido| 
			linea = Linea.new
			linea.nombre = pedido.cliente.nombre
			linea.apellido = pedido.cliente.apellido
			linea.telefono = pedido.cliente.telefono
			linea.cedula = pedido.cliente.ci
			linea.num_pedido = pedido.id
			linea.cuotas = pedido.cuotas.all(:fecha_de_vencimiento => DateTime.parse(params[:search_start_date])..DateTime.parse(params[:search_end_date])).length
			linea.ultimo_vencimiento = pedido.cuotas.all(:fecha_de_vencimiento.gte => params[:search_start_date], :fecha_de_vencimiento.lte => params[:search_end_date]).last.fecha_de_vencimiento
			linea.bs_cuota = pedido.cuotas.first.valor
			linea.saldo_cuota = pedido.sumar_saldo_pendiente_cuotas(params)
			linea.cobrador = pedido.cobradore_id
			tabla << linea
		end
		busqueda_incluyendo_cuotas = Pedido.buscar_por_start_and_end_cuotas(params, tabla)
		busqueda_despues_de_nombre_y_apellido = Pedido.buscar_por_nombre_y_apellido(params, busqueda_incluyendo_cuotas)
		filtrado_por_cobrador = Pedido.filtrado_por_cobrador(busqueda_despues_de_nombre_y_apellido, session)
	end

	def self.filtrado_por_cobrador tabla, session
		filtrado_resultado = Array.new
		tabla.each do |linea|
			if session[:cobradores].include?(linea.cobrador)
				filtrado_resultado << linea
			end
		end
		return filtrado_resultado
	end

	def self.buscar_por_start_and_end_cuotas params,tabla
		resultado_busqueda = Array.new
		if !params[:search_start_cuotas].empty? && !params[:search_end_cuotas].empty?
			tabla.each do |linea|
				if (linea.cuotas >= params[:search_start_cuotas].to_i) && (linea.cuotas <= params[:search_end_cuotas].to_i)
					resultado_busqueda << linea
				end
			end
			return resultado_busqueda
		elsif !params[:search_start_cuotas].empty? && params[:search_end_cuotas].empty?
			tabla.each do |linea|
				if (linea.cuotas >= params[:search_start_cuotas].to_i)
					resultado_busqueda << linea
				end
			end
			return resultado_busqueda
		elsif params[:search_start_cuotas].empty? && !params[:search_end_cuotas].empty?
			tabla.each do |linea|
				if (linea.cuotas <= params[:search_end_cuotas].to_i)
					resultado_busqueda << linea
				end
			end
			return resultado_busqueda
		else
			return tabla
		end
	end


	def self.buscar_por_nombre_y_apellido params, tabla

		resultado_busqueda = Array.new

		if !params[:search_name].empty? && !params[:search_lname].empty?
			tabla.each do |linea|
				if linea.nombre.downcase == params[:search_name].downcase && linea.apellido.downcase == params[:search_lname].downcase
					resultado_busqueda << linea
				end
			end

			return resultado_busqueda

		elsif !params[:search_name].empty? && params[:search_lname].empty?
			tabla.each do |linea|
				if linea.nombre.downcase == params[:search_name].downcase
					resultado_busqueda << linea
				end
			end

			return resultado_busqueda

		elsif params[:search_name].empty? && !params[:search_lname].empty?
			tabla.each do |linea|
				if linea.apellido.downcase == params[:search_lname].downcase
					resultado_busqueda << linea
				end
			end

			return resultado_busqueda

		else
			tabla
		end

	end

	def self.buscar_por_fecha params
		if params[:search_start_date].empty? && !params[:search_end_date].empty?
			Pedido.all(:cuotas => [{:fecha_de_vencimiento.lte => DateTime.parse(params[:search_end_date])}])
		elsif !params[:search_start_date].empty? && params[:search_end_date].empty?
			Pedido.all(:cuotas => [{:fecha_de_vencimiento.gte => DateTime.parse(params[:search_start_date])}])
		elsif !params[:search_start_date].empty? && !params[:search_end_date].empty?
			Pedido.all(:cuotas => [{:fecha_de_vencimiento => DateTime.parse(params[:search_start_date])..DateTime.parse(params[:search_end_date])}])
		else
			Pedido.all
		end

	end

	def sumar_saldo_pendiente_cuotas params
		@saldo_pendiente = 0 
		self.cuotas.all(

		 	             :fecha_de_vencimiento.gte => params[:search_start_date],
		                 :fecha_de_vencimiento.lte => params[:search_end_date]

		                ).each do |cuota|
		 	@saldo_pendiente = @saldo_pendiente + (cuota.valor - cuota.saldo)
		end
		@saldo_pendiente
	end
end

class Cliente
	include DataMapper::Resource
	property :ci, String, :key => true, :length => 15
	property :nombre, String, :length => 40
	property :apellido, String, :length => 40
	property :telefono, String, :length => 10
	has n, :records, :through => Resource
	has n, :pedidos
end
class Record
	include DataMapper::Resource
	property :id, Serial
	property :mensaje, Text
	property :fecha, DateTime
	belongs_to :user
	has n, :clientes, :through => Resource
end

class Cuota
	include DataMapper::Resource
	property :id, Serial
	property :fecha_de_vencimiento, DateTime
	property :valor, Float
	property :saldo, Float
	property :nro_cuota, Float
	belongs_to :pedido

	def solvente? 
		self[:valor] > self[:saldo] ? false : true
	end

	def insolvente? 
		self[:valor] < self[:saldo] ? false : true
	end
end

class Messages_config
	include DataMapper::Resource
	property :id, Serial
	property :passport, String
	property :password, String
end