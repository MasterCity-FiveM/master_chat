ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) Citizen.Wait(0) end
	Citizen.Wait(100)
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

RegisterNetEvent("master_keymap:n5")
AddEventHandler("master_keymap:n5", function()
	SendNUIMessage({
		action = "show"
	})
	SetNuiFocus(true, true)
end)

RegisterNetEvent("master_chat:reciveMessage")
AddEventHandler("master_chat:reciveMessage", function(message)
	xPlayerID = GetPlayerServerId(PlayerId())
	if xPlayerID == message.sender then
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
				exports.pNotify:SendNotification({text = message.name .. ": " .. message.message, type = "info", layout = 'topLeft', timeout = 1000})
			end
			
			SendNUIMessage({
				action = "receive_message",
				message = message.message,
				name = message.name,
				message_type = message.message_type
			})
		end
	elseif message.message_type == 'error' then
		SendNUIMessage({
			action = "receive_message",
			message = message.message,
			name = message.name,
			message_type = message.message_type
		})
	end
end)