module Homework
	
	DEFAULT = 0
	SUBJECT = 1
	HOMEWORK = 2
	FINISH = 3
	
end

def update_homework(homework_folder)
	
	#Obtain all the files of the homework folder.
	#Obtener todos los archivos de la carpeta de tareas.
	tasks = (Dir.entries(homework_folder)-['.']-['..']).sort!
	tasks.each_index do |i|
	
		#Rename the file to i. With this, the homeworks will always be in range 0-n. My method of read and write homeworks depends on this.
		#Renombrar el archivo al numero i actual. De esta forma siempre estaran del 0 al n. Mi metodo de leer y escribir tareas depende de que sea así.
		File.rename("#{homework_folder}/#{tasks[i]}","#{homework_folder}/#{i}.txt") unless tasks[i] == "#{i}.txt"
		
	end
	
end
