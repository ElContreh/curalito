def run(user)

	message = user.message
	if message.text.index(' ') != nil
		arguments = message.text.slice(message.text.index(' ')+1..message.text.length)
	else arguments = ''
	end

	if (numero = arguments.match(/(\d+)\s(\d+)/)) == nil
		BOT.api.send_message(chat_id: message.chat.id, text: I18n.t('rn.notvalid'), reply_to_message_id: message.message_id)
		user.dump = true
		return
	end
	
	if numero[1].to_i < numero[2].to_i
		BOT.api.send_message(chat_id: message.chat.id, text: "#{rand(numero[1].to_i..numero[2].to_i)}", reply_to_message_id: message.message_id)
	else
		BOT.api.send_message(chat_id: message.chat.id, text: I18n.t('rn.greatererror'), reply_to_message_id: message.message_id)
	end
	user.dump = true

end
