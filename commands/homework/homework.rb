require_relative '../../dependencies/hw-dep.rb'

def reflint(message) #Remove First Letter (And convert to integer) / Quitar Primera Letra (Y convertir en integer)
	message.slice(1..message.length).to_i
end

def month_number(month)

	case month
	when 1,3,5,7,8,10,12
		return 31
	when 4,6,9,11
		return 30
	when 2
		if Time.now.year % 4 == 0 && (Time.now.year % 100 != 0 || Time.now.year % 400 == 0)
			return 29
		else
			return 28
		end
	end
end


def run(user)
	message = user.message
	BOT.api.send_message(chat_id: message.chat.id, text: I18n.t('homework.homeworkstart'), reply_to_message_id: message.message_id, reply_markup: Telegram::Bot::Types::ForceReply.new(force_reply: true, selective: true))
	user.state = Homework::SUBJECT
end

def state(user)

	message = user.message
	m = message.message
	homework_folder = "chats/#{m.chat.id.to_s}/homeworks"
	
	
	case user.state
		
	when Homework::SUBJECT
		
		BOT.api.send_message(chat_id: message.chat.id, text: I18n.t('homework.subject').ctv([message.text]), reply_to_message_id: message.message_id, reply_markup: Telegram::Bot::Types::ForceReply.new(force_reply: true, selective: true))
		#BOT.api.deleteMessage(chat_id: user.message.message.chat.id, message_id: user.message.message.message_id)
		user.message = message
		user.state = Homework::HOMEWORK
		user.subject = message.text
		user.homework = ""
			
			
	when Homework::HOMEWORK
		
		case message
		when Telegram::Bot::Types::CallbackQuery
			
			#If the input of the user was of the day, show the month selector. If not, it means that they have already put the day, so it pass to the month, then the hour and finally the minutes.
			#Si la informacion que puso el usuario fue del dia, poner para que ahora ponga la del mes. Si no, significa que ya la puso, por lo que pasa a la hora, y por ultimo a los minutos.
			case message.data.chr 
			when 'n'
				#If it's 'n' it means that the user put "No", so we skip the date proccess.
				#Si es 'n', significa que puso "No", por lo cual nos saltamos el proceso de poner fecha.
				user.date[0] = 0
				kb = Array.new
				text = I18n.t('homework.nodate')
				
				
			when 'm'
				#If it's m, save the data and show the day keyboard.
				#Si es m, guardar el dato que puso, y poner el teclado para que ponga los dias.
				user.date[0] = 1
				user.date[1] = reflint(message.data)
				numero_mes = month_number(reflint(message.data))
				kb = keys(numero_mes,1,'d',8,1)
				text = I18n.t('homework.month')
				
			when 'd'
				#If it's d, save the data and show the hour keyboard.
				#Si es d, guardar ese dato, y poner el teclado para que ponga la hora entonces.
				user.date[2] = reflint(message.data)
				kb = keys(24,1,'h',6,0)
				text = I18n.t('homework.day')
				
			when 'h'
				#If it's h, save the data and show the minute keyboard.
				#Si es h, guardar y poner para los minutos.
				user.date[3] = reflint(message.data)
				kb = keys(60,5,'i',6,0)
				text = I18n.t('homework.hour')
				
			else
			
				user.date[4] = reflint(message.data)
				text = I18n.t('homework.finish')
				
			end
			
			markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
			#Edit the original message so it shows the next thing to do.
			#Editar el mensaje original para mostrar lo siguiente que tiene que hacer.
			BOT.api.edit_message_text(message_id: m.message_id, chat_id: m.chat.id,inline_message_id: message.inline_message_id, reply_markup: markup, text: text)
			
			
			if message.data.chr == 'i' || message.data.chr == 'n'
				user.state = Homework::FINISH
				state(user)
			end
			
		when Telegram::Bot::Types::Message
			if user.homework == ""
				user.homework = message.text
				kb = keys(12,1,'m',6,1)
				kb.unshift(Telegram::Bot::Types::InlineKeyboardButton.new(text: 'No', callback_data: 'n'))
				markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
				BOT.api.send_message(chat_id: message.chat.id, text: I18n.t('homework.date'), reply_to_message_id: message.message_id, reply_markup: markup)
			end
			
		end
		
		
		
		
	when Homework::FINISH
		
		if user.date[0] == 1
			tiempo = Time.new(Time.now.year,user.date[1],user.date[2],user.date[3],user.date[4])
			date = tiempo.strftime("%d/%m %H:%M")
			
			BOT.api.send_message(chat_id: m.chat.id, text: I18n.t('homework.end').ctv([user.subject,user.homework,date]), reply_to_message_id: m.message_id)
		else
			date = "N/A"
			BOT.api.send_message(chat_id: m.chat.id, text: I18n.t('homework.endnodate').ctv([user.subject,user.homework]), reply_to_message_id: m.message_id)
		end
		
		
		Dir.mkdir("chats/#{m.chat.id.to_s}") if !File.exists?("chats/#{m.chat.id.to_s}")
		Dir.mkdir(homework_folder) if !File.directory?(homework_folder)
		update_homework(homework_folder)
		
		inthw = (Dir.entries(homework_folder)-['.']-['..']).length
		File.open("#{homework_folder}/#{inthw}.txt",'w') do |archivo|
			archivo.puts("#{message.from.username} #{message.from.id}\n#{date}\n#{user.subject}\n|f°|\n#{user.homework}")
		end
			
		user.dump = true
		
	end
	
end

def keys(numero,step,letra,separacion,suma)

	c = 0 #Line indexer. / Contador de filas
	f = 0 #Button in a line indexer. / Contador de botones en una fila
	kb = Array.new #Keyboard / Teclado
	kb << Array.new
	
	0.step(numero-1,step) do |i|
		kb[c] << Telegram::Bot::Types::InlineKeyboardButton.new(text: (i+suma).to_s, callback_data: letra+(i+suma).to_s)
		if f > separacion
			kb << Array.new
			c+=1
			f = 0
		else
			f +=1
		end
	end
	
	return kb

end
