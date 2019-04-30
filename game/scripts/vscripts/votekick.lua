--Selena Gomez
isInProgress = false
voteTimer = false
victimId = nil
victimName = nil
voteTable = {}
totalVotes = 0
playerTable = {}
playerList = ""

VoteKick = VoteKick or {}

--This shouldn't be here but we can organize later
   Timers:CreateTimer({
    useGameTime = false,
    endTime = 90, 
    callback = function()
      GameRules:SendCustomMessage("<B><font color='#FFFF00'> Thanks for playing Dota 12v12 2.0 - please post suggestions on the workshop group page.", 0, 0)
   end
   })

function InitiateVoteKick(initiator, victim)
  if voteTimer then
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(tonumber(initiator)), "display_custom_error", { message = "Voting is currently on cooldown, please try again later." })
  else
    if isInProgress then
      CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(tonumber(initiator)), "display_custom_error", { message = "Vote already in progress." })
    else
      victimId = tonumber(victim)
      if victimId then
        if victimId <= 23 then
        initiatorName = PlayerResource:GetPlayerName(initiator)
        victimName = PlayerResource:GetPlayerName(victimId)
          if victimName then
            isInProgress = true
            totalVotes = 0
          
            for i=0, 23 do
              voteTable[i] = 2
            end
            
            CustomGameEventManager:Send_ServerToAllClients("display_vote_kick", { initiator = initiatorName, victim = victimName })
            GameRules:SendCustomMessage("<B><font color='#FFFF00'>" .. initiatorName .. " initiated votekick of <font color='#FF0000'>" .. victimName .. "</font></B>", 0, 0)
       
            Timers:CreateTimer({
              useGameTime = false,
              endTime = 30, 
              callback = function()
                EndVote()
              end
            })
         
            --CustomGameEventManager:Send_ServerToTeam(PlayerResource:GetTeam(keys.playerid), "display_custom_error", { message = PlayerResource:GetPlayerName(keys.playerid) .. " initiated a votekick of " .. victimName })
            --CustomGameEventManager:Send_ServerToTeam(PlayerResource:GetTeam(keys.playerid), "display_custom_error", { message = "team test" })
            --CustomGameEventManager:Send_ServerToPlayer(keys.userid, "display_custom_error", { message = "Test" })
          end
        end
      end
    end
  end
end

function SubmitVote(playerId, answer)
  if isInProgress then
   if voteTable[playerId] == 2 then
    voteTable[playerId] = tonumber(answer)
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(tonumber(playerId)), "display_custom_error", { message = "#votekick_accepted" })
   else
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(tonumber(playerId)), "display_custom_error", { message = "#votekick_already_voted" })
   end
  else
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(tonumber(playerId)), "display_custom_error", { message = "#votekick_no_vote_in_progress" })
  end
end

--EndVote
function EndVote()
  CustomGameEventManager:Send_ServerToAllClients("hide_vote_kick", { var = "" })

  for k, v in pairs(voteTable) do
    if v == 1 then
      totalVotes = totalVotes + 1
    end
    print (totalVotes)
  end
  
  isInProgress = false
  VoteCooldown()
  
  votePercent = totalVotes / CountPlayers() * 100
  if votePercent >= 60 then
    GameRules:SendCustomMessage("<B><font color='#FFFF00'> Voting <font color='#136207'>PASSED: " .. totalVotes .. "/" .. tostring(CountPlayers()) .. " (" .. votePercent .. "%)", 0, 0)
      _G.kicks[victimId+1] = true
      CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(victimId), "setkicks", {kicks = _G.kicks})
  else
    GameRules:SendCustomMessage("<B><font color='#FFFF00'> Vote kick FAILED: " .. totalVotes .. "/" .. tostring(CountPlayers()) .. " (" .. votePercent .. "%)", 0, 0)
  end
  
end

--Util
function VoteCooldown()
voteTimer = true

   Timers:CreateTimer({
    useGameTime = false,
    endTime = 120, 
    callback = function()
      voteTimer = false
   end
   })
         
end

