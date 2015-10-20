ENV['RACK_ENV'] = 'test'

require './init.rb'
require 'test/unit'
require 'rack/test'
require 'pry'


class HelloWorldTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def test_datetime_with_utf_match_with_datamapper_format
    cuota = Cuota.first
    assert(cuota.fecha_de_vencimiento == DateTime.parse('2015-1-1'))
  end

  def session
    user = User.first
    cobradores = Array.new
    user.cobradores.each do |cobrador|
      cobradores << cobrador.id
    end
    {:user => user.nick, :admin => true, :id => user.id, :cobradores => cobradores}

  end

  def test_it_save_user_cobradore_relasionship
    

  def params
    {
    search_start_date: '2015-1-1', 
    search_end_date: '2015-4-4',
    search_start_cuotas: '',
    search_end_cuotas: '',
    search_name: '',
    search_lname: '' }
  end 

  def app
    Sinatra::Application
  end

  def test_it_shows_only_session_cobradore_pedidos
    #hipotetic session start
    
    user = User.first
    session[:user] = user.nick
    session[:admin] = true if user.admin?
    session[:id] = user.id
    session[:cobradores] = user.cobradores.all

    pedidos = Pedido.pendientes(params, session)

    pedidos.each do |pedido|
      assert session[:cobradores].include?(pedido.cobrador)
    end

  end

  def test_it_search_pedidos_pendientes
    lineas = Pedido.pendientes(params, session)
    linea = lineas.first
    cliente = Cliente.first(:nombre => 'Nerio')

    assert_equal linea.nombre, cliente.nombre
    assert_equal linea.apellido, cliente.apellido
    assert_equal linea.telefono, cliente.telefono
    assert_equal linea.num_pedido, cliente.pedidos.first.id    
    assert_equal linea.cuotas, cliente.pedidos.first.cuotas.all(:fecha_de_vencimiento => DateTime.parse(params[:search_start_date])..DateTime.parse(params[:search_end_date])).length
    assert_equal linea.ultimo_vencimiento, cliente.pedidos.first.cuotas.all(:fecha_de_vencimiento => DateTime.parse(params[:search_start_date])..DateTime.parse(params[:search_end_date])).last.fecha_de_vencimiento
    assert_equal linea.bs_cuota, cliente.pedidos.first.cuotas.first.valor
    assert_equal linea.saldo_cuota, cliente.pedidos.first.sumar_saldo_pendiente_cuotas(params)
  end

  def test_tabla_busca_por_rango_de_cuotas
    tabla = Pedido.pendientes({
                             :search_name => 'Nerio',
                             :search_lname => 'Navea',
                             :search_start_cuotas => '1',
                             :search_end_cuotas => '2',
                             :search_start_date => '2015-1-1',
                             :search_end_date => '2015-2-19'},
                             session
                            )
    tabla.any? {|linea| linea.cuotas >= params[:search_start_cuotas].to_i && linea.cuotas <= params[:search_end_cuotas].to_i}
  end

  def test_it_search_pedidos
    pedidos = Pedido.all
    assert !(pedidos.empty?)
  end

 end
end
