def run(user)

	message = user.message
	homework_folder = "chats/#{message.chat.id.to_s}/homeworks"
	if message.text.index(' ') != nil
		arguments = message.text.slice(message.text.index(' ')+1..message.text.length)
	else arguments = ''
	end
	
	numero_de_guiones = arguments.scan(/ - /).length
	if (numero_de_guiones < 1 || numero_de_guiones > 2)
		BOT.api.send_message(chat_id: message.chat.id, text: I18n.t('h.struct'), reply_to_message_id: message.message_id)
		return user
	end
	arguments = arguments.split(' - ')
	if arguments.length == 3
		regexp = arguments[2].match(/([0-3]?\d)\/([0-1]?\d)\s([0-2]?\d):([0-5]?\d)/)
		if regexp == nil
			BOT.api.send_message(chat_id: message.chat.id, text: I18n.t('h.novalid'), reply_to_message_id: message.message_id)
			return
		end
		begin
			tiempo = Time.new(Time.now.year,regexp[2].to_i,regexp[1].to_i,regexp[3].to_i,regexp[4].to_i)
			date = tiempo.strftime("%d/%m %H:%M")
		rescue ArgumentError
			BOT.api.send_message(chat_id: message.chat.id, text: I18n.t('h.novalid'), reply_to_message_id: message.message_id)
			return
		end
	else
		date = "N/A"
	end
	
	Dir.mkdir("chats/#{message.chat.id.to_s}") if !File.directory?("chats/#{message.chat.id.to_s}")
	Dir.mkdir(homework_folder) if !File.directory?(homework_folder)
	inthw = (Dir.entries(homework_folder)-['.']-['..']).length
	File.open("#{homework_folder}/#{inthw}.txt",'a') do |archivo|
		archivo.puts("#{user.message.from.username} #{user.message.from.id}\n#{date}\n#{arguments[0]}\n|f°|\n#{arguments[1]}")
	end
	BOT.api.send_message(chat_id: message.chat.id, text: I18n.t('h.success'), reply_to_message_id: message.message_id)
	user.dump = true
	
end
