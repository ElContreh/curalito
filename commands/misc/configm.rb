def run(user)
	configm_path = "userconfig/#{user.message.from.id.to_s}/chatm.txt"
	File.open(configm_path,'w') {|archivo| archivo.puts user.message.chat.id}
	BOT.api.send_message(chat_id: user.message.chat.id, text: I18n.t('m.ready'))
end
