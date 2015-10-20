
require './init.rb'

user = User.create(:nombre => 'Amenodoro', 
             :apellido => 'Melean', 
             :nick => 'amelean',
             :password => '23444',
             :admin => true)

cobradore = user.cobradores.create(:id => 'a', :nombre => 'Amenodoro')
  
cliente = Cliente.create(nombre: 'Nerio',
         apellido: 'Navea',
         ci: '23444619',
         telefono: '4261680282')

pedido = cliente.pedidos.create(id: '1',
      nota_pedido: '', :cobradore_id => 'a')

pedido.cuotas.create(:fecha_de_vencimiento => DateTime.parse('2015-1-1'),
                     :valor => 1000,
                     :saldo => 0,
                     :nro_cuota => 1)

pedido.cuotas.create(:fecha_de_vencimiento => DateTime.parse('2015-2-1'),
                     :valor => 1000,
                     :saldo => 0,
                     :nro_cuota => 2)

pedido.cobradore.create(:id => 'cd2', :nombre => 'Liquid')

cliente = Cliente.create(nombre: 'Daniela',
         apellido: 'Kossan',
         ci: '18749822',
         telefono: '04146224476')

pedido = cliente.pedidos.create(id: '2',
      nota_pedido: '', :cobradore_id => 'cd2')


pedido.cuotas.create(:fecha_de_vencimiento => DateTime.parse('2015-6-1'),
                     :valor => 3000,
                     :saldo => 0,
                     :nro_cuota => 1)

pedido.cuotas.create(:fecha_de_vencimiento => DateTime.parse('2015-2-1'),
                     :valor => 3000,
                     :saldo => 0,
                     :nro_cuota => 2)
