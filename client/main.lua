ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) Citizen.Wait(0) end
	Citizen.Wait(100)
end)

RegisterNetEvent('chat:addSuggestion')
AddEventHandler("chat:addSuggestion", function(name, help, params)
	suggestion = {{
      name = name,
      help = help
    }}
	
	TriggerServerEvent("master_chat:clientCommand", name)
	SendNUIMessage({
		action = "suggestions",
		suggestions = suggestion
	})
end)

RegisterNetEvent('master_chat:ExecClientCommand')
AddEventHandler("master_chat:ExecClientCommand", function(message)
	if message:sub(1, 1) == '/' or message:sub(1, 1) == '.' then
      ExecuteCommand(message:sub(2))
    end
end)
	
RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(xPlayer)
	PlayerData = xPlayer
end)

RegisterNUICallback("closeUI", function()
	SendNUIMessage({
		action = "hide"
	})
	SetNuiFocus(false, false)
end)

RegisterNetEvent('masterking32:closeAllUI')
AddEventHandler('masterking32:closeAllUI', function() 
	SendNUIMessage({
		action = "hide"
	})
	SetNuiFocus(false, false)
end)

RegisterNUICallback('sentMessage', function(data)
	message = {}
	message.message = data.message
	message.coords = GetEntityCoords(PlayerPedId(-1))
	TriggerServerEvent("master_chat:newMessage", message)
end)

RegisterNUICallback('GetSuggestions', function()
	ESX.TriggerServerCallback('master_chat:GetSuggestions', function(Suggestions)
		SendNUIMessage({
			action = "suggestions",
			suggestions = Suggestions
		})
	end)
end)

RegisterNetEvent("master_keymap:t")
AddEventHandler("master_keymap:t", function()
	TriggerEvent("masterking32:closeAllUI")
	Citizen.Wait(100)
	SendNUIMessage({
		action = "show"
	})
	SetNuiFocus(true, true)
end)

RegisterNetEvent("chatMessage")
AddEventHandler("chatMessage", function(msg)
	message = {}
	msg = msg:gsub("%^[0-9]", "")
	message.sender = 0
	message.message_type = 'info'
	message.message = msg
	message.name = "MasterCity.ir"
	TriggerEvent("master_chat:reciveMessage", message)
end)

RegisterNetEvent("chatMessageAlert")
AddEventHandler("chatMessageAlert", function(msg)
	message = {}
	msg = msg:gsub("%^[0-9]", "")
	message.sender = 0
	message.message_type = 'error'
	message.message = msg
	message.name = "MasterCity.ir"
	TriggerEvent("master_chat:reciveMessage", message)
	exports.pNotify:SendNotification({text = message.message, type = "error", layout = 'centerLeft', timeout = 5000})
end)

RegisterNetEvent("chatMessageError")
AddEventHandler("chatMessageError", function(name, msg)
	message = {}
	msg = msg:gsub("%^[0-9]", "")
	message.sender = 0
	message.message_type = 'error'
	message.message = msg
	message.name = name
	TriggerEvent("master_chat:reciveMessage", message)
end)

RegisterNetEvent("master_chat:reciveMessage")
AddEventHandler("master_chat:reciveMessage", function(message)
	xPlayerID = GetPlayerServerId(PlayerId())
	if xPlayerID == message.sender then
		message.message = message.message:gsub("%^[0-9]", "")
		SendNUIMessage({
			action = "sent_message",
			message = message.message,
			name = message.name
		})
		return
	elseif message.message_type == 'local' and message.coords ~= nil then
		local playerCoords = message.coords
		local playerCoords2 = GetEntityCoords(GetPlayerPed(-1))
		if(Vdist(playerCoords.x, playerCoords.y, playerCoords.z, playerCoords2.x, playerCoords2.y, playerCoords2.z) < message.range) then
			
			if message.message_type == 'local' then
				exports.pNotify:SendNotification({text = message.name .. ": " .. message.message, type = "info", layout = 'centerLeft', timeout = 1500})
			end
			
			message.message = message.message:gsub("%^[0-9]", "")
			
			SendNUIMessage({
				action = "receive_message",
				message = message.message,
				name = message.name,
				message_type = message.message_type
			})
		end
	elseif message.message_type == 'error' then
		message.message = message.message:gsub("%^[0-9]", "")
		
		SendNUIMessage({
			action = "receive_message",
			message = message.message,
			name = message.name,
			message_type = message.message_type
		})
	elseif message.message_type == 'info' then
		message.message = message.message:gsub("%^[0-9]", "")
		
		SendNUIMessage({
			action = "receive_message",
			message = message.message,
			name = message.name,
			message_type = message.message_type
		})
	end
end)
