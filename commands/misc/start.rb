def run(user)
	BOT.api.send_message(chat_id: user.message.chat.id, text: I18n.t('start'), reply_to_message_id: user.message.message_id)
end
