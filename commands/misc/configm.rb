require_relative '../../dependencies/userconfig-dep.rb'
def run(user)
	configm_path = "userconfig/#{user.message.from.id.to_s}/chatm.txt"
	config_create(user)
	File.open(configm_path,'w') {|archivo| archivo.puts user.message.chat.id}
	BOT.api.send_message(chat_id: user.message.chat.id, text: I18n.t('m.ready'))
end
