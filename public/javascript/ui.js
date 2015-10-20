$(document).ready(function(){
	function ajaxPostSearchCustomer(){
		$.ajax({
			url: '/customers/ajax_customers_selectable_list',
			type: 'POST',
			data: {
				search_start_date: $('#input_search_start_date').val(),
				search_end_date: $('#input_search_end_date').val(),
				search_start_cuotas: $('#input_search_start_cuotas').val(),
				search_end_cuotas: $('#input_search_end_cuotas').val(),
				search_name: $('#input_search_name').val(),
				search_lname: $('#input_search_lname').val()
			},
			success: function(result){
				console.log("AJAX: Server information has been recieved succefully")
				$('#customer_select_list').empty();
				$('#customer_select_list').html(result);
				$('.check_select_all').click(function(){
				CheckUnCheckAllCustomers();
				 })
				$('#send_sms').click(function(){
					ajaxPostSendSms();
				})
			}
		})
	}

/*
	function ajaxPostSendSms(){
		console.log("Recolecting Customers IDs");
		var customers_id = {};
		console.log("JSON created");
		$('.check_customer').each(function(){
			if ($(this).is(':checked')) {
				customers_id[$(this).attr('id')] = true;
				console.log("Added ID: " + customers_id[$(this).attr('id')]);
			}
		});
		console.log("All IDs added, result: " + customers_id);
		$.ajax({
			url: '/ajax_message',
			type: 'POST',
			data: customers_id,
			success: function(result){

			}
		})

	}
*/
	function ajaxPostSendSms(){
		var data = {lista: [],
					mensaje: $('#smsText').val()
				   };
		console.log('Array data creado');
		var redactar_lista = [];
		$("#fila-cliente").each(function(){
			console.log('Buscando clientes checked true');
			if ($(this).find('.check_customer').is(':checked')) {
				console.log('Cliente Checked encontrado');

				var cliente = {
					nombre:  $.trim($(this).find('#nombre').html()),
					apellido: $.trim($(this).find('#apellido').html()),
					cedula: $.trim($(this).find('#cedula').html()),
					telefono: $.trim($(this).find('#telefono').html()),
					num_pedido:$.trim($(this).find('#telefono').html()),
					cuotas: $.trim($(this).find('#cuotas').html()),
					ultimo_vencimiento: $.trim($(this).find('#ultimo_vencimiento').html()),
					bs_cuota: $.trim($(this).find('#bs_cuota').html()),
					saldo_cuota: $.trim($(this).find('#saldo_cuota').html()),
				};
				redactar_lista.push(cliente);
				console.log('Añadido cliente' + cliente['nombre']);
			}
		})
		data['lista'] = redactar_lista;
		$.ajax({
			url: '/ajax_message',
			type: 'POST',
			dataType: 'json',
			contentType: 'application/json; charset=utf-8',
			data: JSON.stringify(data),
			success: function(result){
				Console.log('Enviada informacion al servidor');
			}
		})
		//alert('Mensaje enviado satisfactoriamente a los clientes seleccionados');
		//location.reload();
	}


	function ajaxPostSendCobradore(){
		console.log("Recolecting Cobradore IDs");
		var cobradoreId = {};
		console.log("JSON created");
		$('.check_customer').each(function(){
			if ($(this).is(':checked')) {
				cobradoreId[$(this).attr('id')] = true;
				console.log("Added ID: " + cobradoreId[$(this).attr('id')]);
			}
		})
		console.log("All IDs added, result: " + cobradoreId);
		$.ajax({
			url: window.location.pathname,
			type: 'PUT',
			data: cobradoreId,
			success: function(result){

			}
		})

	}
    function hideAllPopovers() {
       $('[data-toggle="popover"]').popover('hide')
    }
	function CheckUnCheckAllCustomers(){
		if ($('.check_select_all').is(':checked')){
			$('.check_customer').each(function(){
				$(this).prop('checked', true);
			})
			console.log("removing checks");
		} else {
			$('.check_customer').each(function(){
				$(this).prop('checked',false);
			})
			console.log("adding checks");
		} 
	}
	$('.input-daterange').datepicker({
		orientation: "bottom left",
		format: "yyyy-mm-dd"
	})
	$('.customer_search_control').change(function(){
		console.log(".customer_search_control changed");
		ajaxPostSearchCustomer();
	})
/*	$('#send_sms').click(function(){
		ajaxPostSendSms();
	})
*/
	$(function () {
		$('[data-toggle="tooltip"]').tooltip()
	})
	$(function () {
		$('[data-toggle="popover"]').popover()
	})
	$('.btnCobradores').click(function(){
		hideAllPopovers();
	})
	$('.btnSaveCobrador').click(function(){
		ajaxPostSendCobradore();
		window.location.replace('/admin/users');
	})
	$('.recent-text').click(function(){
		$('#smsText').val($.trim($(this).html()));	
	})
})