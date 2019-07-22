def run(user)
	BOT.api.send_message(chat_id: user.message.chat.id, text: File.read("text/help/help-#{I18n.locale}.txt"), reply_to_message_id: user.message.message_id)
end
