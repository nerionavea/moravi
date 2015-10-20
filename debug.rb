require './init.rb'
params = {
         :search_name => 'Nerio',
         :search_lname => 'Navea',
         :search_start_cuotas => '2',
         :search_end_cuotas => '2',
         :search_start_date => '2015-1-1',
         :search_end_date => '2015-2-19'
         }

tabla = Pedido.pendientes(params)
resultado_busqueda = Array.new
tabla.each do |linea|
	if (linea.cuotas >= params[:search_start_cuotas].to_i) && (linea.cuotas <= params[:search_end_cuotas].to_i)
		resultado_busqueda << linea
	end
end

resultado_busqueda

tabla.each do |linea|
	tabla.delete(linea)
end