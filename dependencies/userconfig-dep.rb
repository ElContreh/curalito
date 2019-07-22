def config_create(user)
	Dir.mkdir("userconfig") if !File.directory?("userconfig")
	Dir.mkdir("userconfig/#{user.message.from.id.to_s}") if !File.directory?("userconfig/#{user.message.from.id.to_s}")
end
