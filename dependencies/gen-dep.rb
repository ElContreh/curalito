require 'telegram/bot'



#Clase con toda la informacion que se necesita del usuario
#Class with all the information that the program needs from the user
class User

	attr_accessor :state, :message, :subject, :homework, :date, :dump, :locale, :command
	def initialize(message)
		@state = 0
		@message = message
		@dump = false
		@date = Array.new
	end
end


#Comandos customizados para el tipo string
#Custom commands for strings.
class String

	#Checkear si el string es un numero rapidamente
	#Check if the string is a number.
	def numeric?
		Float(self) != nil rescue false
	end
	
	def stop_at_space
		if self.count(' ') == 0
			return self
		else
			return self.slice(0..self.index(' ').to_i-1)
		end
	end
	
	#Convert to variable. Used to convert strings in .yml files that are supposed to have variables.
	def ctv(variables)
	
		newString = self
		
		for i in 0..self.scan(/(_\d+_)/).size-1
		
			newString.sub!(/(_\d+_)/,variables[i])
		
		end
		return newString
	end
	
end

class Telegram::Bot::Types::Message

	def message
		return self
	end

end

TOKEN = 'XXXX' #Token bot. Talk to BotFather in Telegram to get one. It is used to tell Telegram what bot is running this program.
NAME = 'curalitobot' #The username of your bot.
BOT = Telegram::Bot::Client.new(TOKEN)

