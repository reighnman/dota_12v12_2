  Timers:CreateTimer({
    endTime = 1, 
    callback = function()
      if IsInToolsMode() then
  print ("In dev mode spawning bots")
  SendToServerConsole("dota_bot_populate")
end
    end
  })

