class SMS
	def initialize()
		@config = Messages_config.first()
		@client = Savon.client(wsdl: 'http://200.41.57.109:8086/m4.in.wsint/services/M4WSIntSR?wsdl')
	end

	def send_masive_sms(text)
		@customers = Customer.all
		@text = File.open('masivo.txt', 'w+')
		@customers.each do |customer|
			transformed_text = text.gsub('(Nombre)', customer.first_name).gsub('(Apellido)', customer.last_name)
			divide_and_send_message(customer.cellphone, transformed_text)
		end
		@text.rewind
	end
	def divide_and_send_message(to,text)
		sended_point = 0
		while text.length > sended_point
			write_line(to, text[sended_point, 160])
			sended_point += 160
		end
	end
	def write_line(to,text)
		@text.puts get_operator_code(to) + ';' + get_number_without_operator_code(to) + ';' + text
	end
	def get_operator_code(number)
		if number[0] == '0'
			number[1,3]
		else
			number[0,3]
		end
	end
	def get_number_without_operator_code(number)
		if number[0] == '0'
			number[4,7]
		else
			number[3,7]
		end
	end
	def send_sms(to,text)
		@client.call(:send_sms, message: {
		'passport' => @config.passport, 
		'password' => @config.password, 
		'number' => convert_number_to_international(to), 
		'text' => text})
	end
	def convert_number_to_international(number)
		#Verify if number its not a real number
		if number.length >= 10 && number.is_a?(Integer)
			'58' + number[-10..10]
		end
	end
end