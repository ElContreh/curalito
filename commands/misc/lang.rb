def run(user)

	userconfig_dir = "userconfig/#{user.message.from.id.to_s}"

	if user.message.text.index(' ') != nil
		arguments = user.message.text.slice(user.message.text.index(' ')+1..user.message.text.length)
	else arguments = ''
	end

	if (regex = arguments.match(/^([a-z]{2})$/))
		Dir.mkdir(userconfig_dir) if !File.directory?(userconfig_dir)
		File.open("#{userconfig_dir}/locale.txt",'w') {|file| file.puts regex[1]}
		I18n.locale = set_locale(user)
		BOT.api.send_message(chat_id: user.message.chat.id, text: I18n.t('lang.success'))
	else
		BOT.api.send_message(chat_id: user.message.chat.id, text: I18n.t('lang.invalid'))
	end	

end
