require 'telegram/bot'
require 'i18n'
require_relative 'dependencies/gen-dep.rb'

I18n.load_path << Dir[File.expand_path("text") + "/*.yml"]

#Methods
#Funciones
def set_user(users, message) 
	
	#Comprobar si ya ha escrito y ver su estado
	#Check if the user has written something already, and see their status.
	v = -1 #Index of the found (or created) user. It's in -1 because it's an impossible number, so I take it as a nil / Index del usuario encontrado (o creado) en el array. Esta en -1 porque es un numero que es imposible que se encuentre en la array
	
	users.each do |userLoop|
	
		#Encontrar al usuario entre el array de usuarios. Si el la id del usuario y la id del chat del usuario en el array coinciden con el autor del mensaje actual, entonces encontramos al usuario en el array.
		#Find de user in the array of users. If the id of the chat and the id of the user match with the author of the current message, then we have found the user in the array.
		if (userLoop.message.from.id == message.from.id) && (userLoop.message.message.chat.id == message.message.chat.id)
			
			v = users.find_index(userLoop)
			break
		end
				
	end
			
	#Si no encuentra, crear un usuario en la posición 0.
	#If we don't find it, we create it in position 0.
	if v == -1 
	
		users.unshift(User.new(message))
		v = 0
			
	end
	
	#Regresar el usuario en el array.
	#Return the user in the array.
	return users[v]


end

def multim(user)
	message = user.message
	configm_path = "userconfig/#{message.from.id.to_s}/chatm.txt"
	userconfig_dir = "userconfig/#{message.from.id.to_s}"
	if !File.exists?(configm_path)
		BOT.api.send_message(chat_id: message.chat.id, text: I18n.t('m.notconfigured'))
		return
	end
	
	begin
		if !message.photo.empty?
			BOT.api.send_photo(chat_id: File.read(configm_path).to_i, photo: message.photo.last.file_id)
		elsif message.sticker != nil
			BOT.api.send_sticker(chat_id: File.read(configm_path).to_i, sticker: message.sticker.file_id)
		elsif message.video != nil
			BOT.api.send_video(chat_id: File.read(configm_path).to_i, video: message.video.file_id)
		elsif message.voice != nil
			BOT.api.send_voice(chat_id: File.read(configm_path).to_i, voice: message.voice.file_id)
		elsif message.video_note != nil
			BOT.api.send_video_note(chat_id: File.read(configm_path).to_i, video_note: message.video_note.file_id)
		end
	rescue
		BOT.api.send_message(chat_id: message.chat.id, text: I18n.t('m.error'))
	end

end

def set_locale(user)

	locale = :en
	locale = File.read("userconfig/#{user.message.from.id}/locale.txt").chomp.to_sym if File.exists?("userconfig/#{user.message.from.id}/locale.txt")
	return locale

end


def check_status(user)
	if !user.command.nil?

		state(user)
		
	end
end


#Main program.
#Programa principal.
def main()

	Dir.mkdir "chats" if !File.directory? "chats"
	Dir.mkdir "userconfig" if !File.directory? "userconfig"
	#Crear una array de usuarios donde guardarlos a todos.
	#Create an array of users to store them all
	users = Array.new
	
	#Loop principal que escucha nuevos mensajes.
	#Main loop that listens to new messages.
	BOT.listen do |message|
	
		#Crear una variable user para tener un acceso mas comodo al usuario en si.
		#Create the user variable to access the user easier in the code.
		user = set_user(users,message)
		user.message = message
		I18n.locale = set_locale(user)
		
		case message
		when Telegram::Bot::Types::Message
			if message.text != nil
				if message.text[0] == '/'
				
					#Commmand
					Dir[File.expand_path("commands") + "/*/*.rb"].each do |path|
					
						if "#{message.text.stop_at_space}.rb" == "/#{File.basename(path)}"
						
							load path
							
							run(user)
							
							user.command = message.text.stop_at_space.sub("/","")
							
						end
						
					end
					
				elsif message.reply_to_message != nil && message.reply_to_message.from.username == NAME
					#Reply
					check_status(user)
					
				end
			elsif message.chat.type == 'private'
				multim(user)
				user.dump = true
			else
				user.dump = true
			end
		when Telegram::Bot::Types::CallbackQuery
			check_status(user)
		end
		
		
		if user.dump == true
			users.delete(user)
		end
	
	
	end

end


log = Logger.new('log.txt')

loop do

	begin
	
		main()
		
	rescue Faraday::ConnectionFailed => err
	
		puts err
		
	rescue StandardError => err
	
		log.fatal(err)
		puts err
		exit
		
	end
	
end


