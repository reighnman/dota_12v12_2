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
    endTime = 45, 
    callback = function()
      GameRules:SendCustomMessage("<B><font color='#FFFF00'> Thanks for playing Dota 12v12 2.0 - votekick is a work in progress, please post suggestions on the workshop group page.", 0, 0)
   end
   })

--HelpCommands
ChatCommand:LinkCommand("-help", "HelpCommands")
ChatCommand:LinkCommand("-commands", "HelpCommands")
ChatCommand:LinkCommand("-?", "HelpCommands")

function HelpCommands(keys)
  GameRules:SendCustomMessage("<B><font color='#FFFF00'> -list : List player ID's, the ID of the player can be used for vote kicking.", 0, 0)
  GameRules:SendCustomMessage("<B><font color='#FFFF00'> -votekick [PlayerID] : Start a vote to kick [PlayerID].", 0, 0)
  GameRules:SendCustomMessage("<B><font color='#FFFF00'> -goldbonus : Check if gold bonus is in effect for underdog team.", 0, 0)
end

--InitiateVoteKick
ChatCommand:LinkCommand("-votekick", "InitiateVoteKick")
ChatCommand:LinkCommand("-vk", "InitiateVoteKick")

function InitiateVoteKick(keys)
  if voteTimer then
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(tonumber(keys.playerid)), "display_custom_error", { message = "Voting is currently on cooldown, please try again later." })
  else
    if isInProgress then
      CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(tonumber(keys.playerid)), "display_custom_error", { message = "Vote already in progress." })
    else
      args = split(keys.text," ")
      victimId = tonumber(args[2])
      if victimId then
        if victimId <= 23 then
        
        victimName = PlayerResource:GetPlayerName(victimId)
        if victimName then
          isInProgress = true
          totalVotes = 0  
          
           for i=0, 23 do
            voteTable[i] = 0
          end
          
          GameRules:SendCustomMessage("<B><font color='#FFFF00'>" .. PlayerResource:GetPlayerName(keys.playerid) .. " initiated votekick of <font color='#FF0000'>" .. victimName .. "</font></B>", 0, 0)
          GameRules:SendCustomMessage("<font color='#FFFF00'> If you wish to vote in favor of this kick, type <font color='#FF0000'>-vote <font color='#FFFF00'>in chat.", 0, 0)
       
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
    else
      HelpCommands()
    end
  end
 end
end

--SubmitVote
ChatCommand:LinkCommand("-vote", "SubmitVote")
ChatCommand:LinkCommand("-Vote", "SubmitVote")
ChatCommand:LinkCommand("-VOTE", "SubmitVote")
function SubmitVote(keys)
  if isInProgress then
   if voteTable[keys.playerid] == 0 then
    voteTable[keys.playerid] = 1
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(tonumber(keys.playerid)), "display_custom_error", { message = "Vote accepted." })
   else
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(tonumber(keys.playerid)), "display_custom_error", { message = "Already voted." })
   end
  else
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(tonumber(keys.playerid)), "display_custom_error", { message = "No vote is in progress." })
  end
end

--EndVote
function EndVote()

  for k, v in pairs(voteTable) do
    if v == 1 then
      totalVotes = totalVotes + 1
    end
    print (totalVotes)
  end
  
  isInProgress = false
  VoteCooldown()
  
  votePercent = totalVotes / CountPlayers() * 100
  if votePercent >= 75 then
    GameRules:SendCustomMessage("<B><font color='#FFFF00'> Voting <font color='#136207'>PASSED: " .. totalVotes .. "/%" .. votePercent, 0, 0)
      _G.kicks[victimId+1] = true
      CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(victimId), "setkicks", {kicks = _G.kicks})
  else
    GameRules:SendCustomMessage("<B><font color='#FFFF00'> Vote kick FAILED: " .. totalVotes .. " / " .. votePercent .. "%", 0, 0)
  end
  
end

--List Players
ChatCommand:LinkCommand("-players", "ListPlayers")
ChatCommand:LinkCommand("-list", "ListPlayers")
ChatCommand:LinkCommand("-lp", "ListPlayers")
function ListPlayers(keys)
  playerList = ""

    for i=0, 23 do
      playerTable[i] = 0
    end
    
    for t=2, 3 do
        for x=0,DOTA_MAX_TEAM do
        local pID = PlayerResource:GetNthPlayerIDOnTeam(t,x)
          if PlayerResource:IsValidPlayerID(pID) and (PlayerResource:GetConnectionState(pID) == 1 or PlayerResource:GetConnectionState(pID) == 2) then
           playerTable[keys.playerid] = PlayerResource:GetPlayerName(keys.playerid)
          end
        end
    end
    
    for k, v in pairs(playerTable) do
      if v ~= 0 then
        GameRules:SendCustomMessage("<B><font color='#FFFF00'>" .. k .. " : " .. v .. "</font></B>", 0, 0)
      end 
    end

    --CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(tonumber(keys.playerid)), "display_custom_error", { message = playerList })
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

