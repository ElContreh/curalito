require 'telegram/bot'
require_relative 'dependencies/gen-dep.rb'

def recordatorio
	dir = 'chats'
	while true
		time = Time.now
		chats = Dir.entries(dir)-['.']-['..']
		chats.each do |chat|
			
			chat.gsub!(' - y','')
			dir2 = "#{dir}/#{chat}/homeworks"
			homeworks = Dir.entries(dir2)-['.']-['..']
			homeworks.each do |homework|
			
				text = IO.readlines(dir2+'/'+homework)
				#p tiempo.strftime("%d/%m %H:%M")
				#p texto[1].chomp
				if time.strftime("%d/%m %H:%M") == text[1].chomp
					BOT.api.send_message(chat_id: chat.to_i, text: I18n.t('reminder').ctv([lineas[2..lineas.index("|f°|")-1].join("\n")]))
				end
			
			
			end
			
		end
		
		sleep 60
	end
	
end

recordatorio()
