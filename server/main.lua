ESX = nil
LastChats, Commands, Suggestions = {}, {}, {}
ServerName = "MasterCity.iR"
-- Whitelist commands to run without aduty.
Whiltelist_commands = {
	aduty = true,
	gm = true,
	a = true,
}

TriggerEvent("esx:getSharedObject", function(obj) 
	ESX = obj
end)

while ESX == nil do
	Citizen.Wait(1)
end
Citizen.CreateThread(function()
	while ESX == nil or ESX.Items == nil or #ESX.Items < 1 do
		TriggerEvent("esx:getSharedObject", function(obj) 
			ESX = obj
		end)
		
		Citizen.Wait(500)
	end
end)

ESX.AddCustomFunction("AddCommand", function(name, rank, cb, params, help, ctype)
	if type(name) == 'table' then
		for k,v in ipairs(name) do
			namev = v:lower()
			Commands[namev] = {}
			Commands[namev].rank = rank
			Commands[namev].name = namev
			Commands[namev].cb = cb
			Commands[namev].params = params
			Commands[namev].help = help
			Commands[namev].type = ctype
			Suggestions[namev] = {}
			Suggestions[namev].name = Commands[namev].type .. namev
			Suggestions[namev].help = help
		end

		return
	end
	
	name = name:lower()
	Commands[name] = {}
	Commands[name].rank = tonumber(rank)
	Commands[name].name = name
	Commands[name].cb = cb
	Commands[name].params = params
	Commands[name].help = help
	Commands[name].type = ctype
	Suggestions[name] = {}
	Suggestions[name].name = Commands[name].type .. name
	Suggestions[name].help = help
end)

ESX.RegisterServerCallback('master_chat:GetSuggestions', function(source, cb)
	ESX.RunCustomFunction("anti_ddos", source, 'master_chat:GetSuggestions', {})
	cb(Suggestions)
end)

RegisterNetEvent('master_chat:newMessage')
AddEventHandler('master_chat:newMessage', function(message)
	ESX.RunCustomFunction("anti_ddos", source, 'master_chat:newMessage', {message = message})
	_source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	if xPlayer == nil or not xPlayer or xPlayer.identifier == nil or message == nil or message.message == nil or message.message == "" then
		return
	end
	
	sent_message = {}
	message.message = message.message:gsub("<", "")
	message.message = message.message:gsub(">", "")
	sent_message.message = message.message
	
	sent_message.name = xPlayer.firstname .. " " .. xPlayer.lastname
	sent_message.name = sent_message.name:gsub("<", "")
	sent_message.name = sent_message.name:gsub(">", "")
	
	sent_message.sender = _source
	sent_message.coords = message.coords
	sent_message.range = 15
	sent_message.message_type = 'local'
	
	if isCommand(sent_message.message, _source, sent_message) then
		return
	end
	
	identifierArName = xPlayer.identifier:gsub(":", "")
	if LastChats[identifierArName] ~= nil and LastChats[identifierArName] + 2 > tonumber(os.time()) then
		return
	end
	
	if message.message:len() > 350 then
		return
	end
	
	LastChats[identifierArName] = tonumber(os.time())
	TriggerClientEvent("master_chat:reciveMessage", -1, sent_message)
end)

function ExecuteMCommand(command, src, message)
	local xPlayer = ESX.GetPlayerFromId(src)
	if xPlayer == nil or not xPlayer or Commands[command:lower()] == nil then
		return
	end
	
	local command_data = Commands[command:lower()]
	
	args = {}
	sent_message = {}
	sent_message.name = ServerName
	sent_message.sender = 0
	
	if Commands[command:lower()].rank > xPlayer.getRank() then
		sent_message.message_type = 'error'
		sent_message.message = 'شما دسترسی لازم برای اجرای این دستور را ندارید.'
		TriggerClientEvent("master_chat:reciveMessage", src, sent_message)
		return
	end
	
	if Commands[command:lower()].rank > 0 and xPlayer.get("aduty") ~= true and Whiltelist_commands[command:lower()] == nil then
		sent_message.message_type = 'error'
		sent_message.message = 'لطفا حالت گیم مستر خود را فعال کنید.'
		TriggerClientEvent("master_chat:reciveMessage", src, sent_message)
		return
	end
	
	if command_data.params ~= nil and #command_data.params > 0 then
		splited_args = mysplit(message, " ") -- arg 1 is command.
		local hasError = false
		if #splited_args + 1 < #command_data.params then
			hasError = true
		end
		if not hasError then
			for k,v in ipairs(command_data.params) do
				k2 = k + 1
				if v.type then
					if v.type == 'number' then
						local newArg = tonumber(splited_args[k2])

						if newArg then
							args[v.name] = newArg
						else
							hasError = true
						end
					elseif v.type == 'player' or v.type == 'playerId' then
						local targetPlayer = tonumber(splited_args[k2])

						if splited_args[k2] == 'me' then targetPlayer = src end

						if targetPlayer then
							local xTargetPlayer = ESX.GetPlayerFromId(targetPlayer)

							if xTargetPlayer then
								if v.type == 'player' then
									args[v.name] = xTargetPlayer
								else
									args[v.name] = targetPlayer
								end
							else
								hasError = true
							end
						else
							hasError = true
						end
					elseif v.type == 'string' then
						args[v.name] = splited_args[k2]
					elseif v.type == 'item' then
						if ESX.Items[splited_args[k2]] then
							args[v.name] = splited_args[k2]
						else
							hasError = true
						end
					elseif v.type == 'weapon' then
						if ESX.GetWeapon(splited_args[k2]) then
							args[v.name] = string.upper(splited_args[k2])
						else
							hasError = true
						end
					elseif v.type == 'any' then
						args[v.name] = splited_args[k2]
					elseif v.type == 'full' then
						args[v.name] = splited_args[k2]
						for k3,v3 in ipairs(splited_args) do
							if k2 < k3 then
								args[v.name] = args[v.name] .. ' ' .. splited_args[k3]
							end
						end
					end
				end

				if hasError then break end
			end
		end
		
		if hasError then
			sent_message.message_type = 'error'
			sent_message.message = 'دستور به درستی وارد نشده است.'
			TriggerClientEvent("master_chat:reciveMessage", src, sent_message)
			return
		end
		
		command_data.cb(xPlayer, args)
		return
	end
	
	command_data.cb(xPlayer, args)
end

function isCommand(message, src, sent_message)
	local ss =  string.sub(message, 1, 1)
	if ss == "/" or ss == '.' then
		spilted = mysplit(message, " ")
		if spilted[1] ~= nil then
			CommandKey = spilted[1]:sub(2)
			if CommandKey ~= nil and Commands[CommandKey:lower()] ~= nil and Commands[CommandKey:lower()].type == ss then
				CommandKey = CommandKey:lower()
				sent_message.message = "Command: " .. sent_message.message
				TriggerClientEvent("master_chat:reciveMessage", src, sent_message)
				ExecuteMCommand(CommandKey, src, message)
				return true
			else
				TriggerClientEvent("master_chat:reciveMessage", src, sent_message)
				TriggerClientEvent("master_chat:ExecClientCommand", src, message)
				return true
			end
		end
	end
	
	return false
end

function mysplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	
	local t={}
	
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	
	return t
end
