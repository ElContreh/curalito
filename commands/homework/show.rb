def run (user)

	message = user.message
	homework_folder = "chats/#{message.chat.id.to_s}/homeworks"
	
	#If the homework folder doesn't exist or if it's empty, inform it to the user.
	#Si la carpeta de tareas no existe, o si esta vacia, informarle de eso al usuario.
	if (!File.directory?(homework_folder)) || (tasks = Dir.entries(homework_folder)-['.']-['..']).empty?
		BOT.api.send_message(chat_id: message.chat.id, text: I18n.t('show.nohw'), reply_to_message_id: message.message_id)
		user.dump = true
		return
	end
	
	mostrar = ""
	update_homework(homework_folder)
	tasks.each_index do |i|
		lineas = IO.readlines("#{homework_folder}/#{i}.txt")
		lineas.each{|x| x.chomp!}
		subject = lineas[2..lineas.index("|f°|")-1].join("\n")
		homework = lineas[lineas.index("|f°|")+1..lineas.length-1].join("\n")
		date = lineas[1]
		autor = lineas[0].slice(0..lineas[0].index(' ')-1)
		if user.message.chat.type == 'private'
			mostrar += "\u{1F449} #{subject} - #{homework} (#{date})\n"
		else
			mostrar += "\u{1F449} #{subject} - #{homework} (#{date})" + I18n.t('show.added') + "@#{autor}\n"
		end
	end
	BOT.api.send_message(chat_id: message.chat.id, text: mostrar, reply_to_message_id: message.message_id)
	user.dump = true
	
end
