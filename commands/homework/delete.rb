require_relative '../../dependencies/hw-dep.rb'
def run(user)

	message = user.message
	homework_folder = "chats/#{message.chat.id.to_s}/homeworks"
	
	#If the homework folder doesn't exist or if it's empty, tell the user that they don't have homeworks to delete.
	#Si el directorio de tareas no existe, decirle al usuario que no tiene tareas que borrar.
	if !File.directory?(homework_folder)
		BOT.api.send_message(chat_id: message.chat.id, text: I18n.t('delete.nohw'), reply_to_message_id: message.message_id)
		user.dump = true
		return
	end
	botones = update_keyboard(homework_folder,message.from.id) #Actualizar (en este caso, crear) el teclado de botones con todas las tareas.
	teclado = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: botones)
	BOT.api.send_message(chat_id: message.chat.id, text: I18n.t('delete.list'), reply_markup: teclado, reply_to_message_id: message.message_id)
	
end

def state(user)
	message = user.message
	m = message.message
	homework_folder = "chats/#{m.chat.id.to_s}/homeworks"

	#If the received message is "Finished", the operation finishes. If it's not, it continues.
	#Si el mensaje recibido es "Finished", se termina la operacion. Si no es asi, continua.
	if message.data == 't'
		update_homework(homework_folder)
		teclado = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: Array.new)
		BOT.api.edit_message_text(message_id: m.message_id, chat_id: m.chat.id, inline_message_id: message.inline_message_id, reply_markup: teclado, text: I18n.t('delete.finished'))
		user.dump = true
		return
	end
	
	#Convert the index to integer.
	#Convertirlo en numero.
	index = message.data.chr
	
	#If it doens't exist, do nothing.
	#Si no existe, no hacer nada.
	return if !File.exist?(archivo = "#{homework_folder}/#{index}.txt")
	
	#Proceed to delete the file.
	#Proceder a eliminar el archivo.
	File.delete(archivo)
	
	#Update the keyboard so it shows the changes.
	#Actualizar el teclado para mostrar los cambios.
	teclado = update_keyboard(homework_folder,message.from.id)
	
	#Show the updated keyboard.
	#Mostrar el teclado actualizado.
	teclado = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: teclado, selective: true)
	
	#Inform the user that the deletion went okay.
	#Confirmar que la operacion salio bien.
	BOT.api.edit_message_text(message_id: m.message_id, chat_id: m.chat.id, inline_message_id: message.inline_message_id, reply_markup: teclado, text: I18n.t('delete.continue'))
	
end


def update_keyboard(homework_folder,idUser)

	teclado = Array.new
	teclado << Array.new # [ [ ] ]
	#Obtain all the files of the homework folder.
	#Obtener todos los archivos de la carpeta de tareas.
	tareas = (Dir.entries(homework_folder)-['.']-['..']).sort!
	p tareas
	c = 0 #Line indexer. / Contador de filas.
	tareas.each_index do |i|
		
		#Rename the file to i. With this, the homeworks will always be in range 0-n. My method of read and write homeworks depends on this.
		#Renombrar el archivo al numero i actual. De esta forma siempre estaran del 0 al n. Mi metodo de leer y escribir tareas depende de que sea así.
		File.rename("#{homework_folder}/#{tareas[i]}","#{homework_folder}/#{i}.txt") unless tareas[i] == "#{i}.txt"
		
		#Obtain all the lines in the i.txt file. Chomp the carriage return so it's more comfortable.
		#Obtener las lineas del archivo i.txt. Quitarles el salto de linea para una escritura mas cómoda.
		lineas = IO.readlines("#{homework_folder}/#{i}.txt").each{|x| x.chomp!}
		
		#Obtain the id. With this, we verify if the homework was made by the current user. If not, continue to the next homework.
		#Obtener el id. Esto es para verificar si la tarea fue hecha por el usuario actual. Si no es así, seguir a la siguiente tarea.
		id = lineas[0].slice(lineas[0].index(' ')+1..lineas[0].length-1).to_i
		next if id != idUser
		
		subject = lineas[2..lineas.index("|f°|")-1].join("\n")
		homework = lineas[lineas.index("|f°|")+1..lineas.length-1].join("\n")
		
		#Add in the current line a button with the obtained homework.
		#Agregar en la fila actual un boton con la tarea
		teclado[c] << Telegram::Bot::Types::InlineKeyboardButton.new(text: "#{subject} - #{homework}", callback_data: i)
		
		#If c is greater or equal than 2 (hard coded for aesthetic purposes), add a new line of buttons.
		#Si c es mayor o igual a 2 (numero forzado por cuestiones de estetica), agregar una nueva fila de botones.
		if teclado[c].count >= 2
			teclado << Array.new
			c+=1
		end
		
	end
	
	#Add the finish button in his own line.
	#Agregar el botón para terminar en su propia fila
	teclado << Array.new
	teclado[c+1] << Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Terminado', callback_data: 't')
	
	return teclado
end
