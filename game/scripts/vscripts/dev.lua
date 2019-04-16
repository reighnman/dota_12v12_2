if IsInToolsMode() then
  
  Timers:CreateTimer({
    endTime = 1, 
    callback = function()
    print ("In dev mode spawning bots")
    SendToServerConsole("dota_bot_populate")

  end
  })

-- Debug output timers for troubleshooting
  Timers:CreateTimer({
    endTime = 1, 
    callback = function()

		--local modifierTable = debugUnit:FindAllModifiers()
		--for i, modifier in ipairs(modifierTable) do
		--	print( "modifierTable["..tostring(i).."] = "..modifier:GetName() )
		--end

    return 5
  end
  })

end

