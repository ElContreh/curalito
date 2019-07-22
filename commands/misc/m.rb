def run(user)
	
	message = user.message
	configm_path = "userconfig/#{message.from.id.to_s}/chatm.txt"
	userconfig_dir = "userconfig/#{user.message.from.id.to_s}"
	if message.text.index(' ') != nil
		arguments = message.text.slice(message.text.index(' ')+1..message.text.length)
	else arguments = ''
	end

	if arguments == ''
		user.dump = true
		return
	end
		
	begin
	
		Dir.mkdir(userconfig_dir) if !File.directory?(userconfig_dir)
		
		if !File.exists?(configm_path)
			
			BOT.api.send_message(chat_id: message.chat.id, text: I18n.t('m.notconfigured'))
			user.dump = true
			return
			
		end
		
		BOT.api.send_message(chat_id: File.read(configm_path).to_i, text: arguments)
		
	rescue Telegram::Bot::Exceptions::ResponseError
	
		BOT.api.send_message(chat_id: message.chat.id, text: I18n.t('m.error'))
		
	end
	
	user.dump = true

end
