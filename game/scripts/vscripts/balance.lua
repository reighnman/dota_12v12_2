require('utility_functions')

Balance = Balance or {}

--Balance functions
GOLD_BONUS_PP_PS = 1 --Per Player, Per Second (1 = 60gpm per player missing or 300gpm per 5 players missings)
GOODGUYSQTY = 0
BADGUYSQTY = 0
GOLDBONUS = 0
BONUSTEAM =  "RADIANT"
goldBonusActive = false

--After 2 minutes start tracking team sizes for bonus gold
Timers:CreateTimer("timerPlayerCounts", {
    endTime = 30,
    callback = function()
        GOODGUYSQTY = GetActivePlayerCountForTeam(DOTA_TEAM_GOODGUYS)
        BADGUYSQTY = GetActivePlayerCountForTeam(DOTA_TEAM_BADGUYS)
      return 10
    end
})

--This shouldn't be here but we can organize later
Timers:CreateTimer("timerGoldBonus", {
    endTime = 390, --begin roughly 5min in 390
    callback = function()
        if (GOODGUYSQTY < BADGUYSQTY) then
            local multi = BADGUYSQTY - GOODGUYSQTY
            GOLDBONUS = multi * GOLD_BONUS_PP_PS
            GrantBonusGold(DOTA_TEAM_GOODGUYS, GOLDBONUS)
            goldBonusActive = true
            BONUSTEAM = "RADIANT"
            CustomGameEventManager:Send_ServerToAllClients("update_bonus_gold_display", { team = BONUSTEAM, gpm = GOLDBONUS*60 })
        elseif (BADGUYSQTY < GOODGUYSQTY) then
            local multi = GOODGUYSQTY - BADGUYSQTY
            GOLDBONUS = multi * GOLD_BONUS_PP_PS
            GrantBonusGold(DOTA_TEAM_BADGUYS, GOLDBONUS)
            goldBonusActive = true
            BONUSTEAM = "DIRE"
            CustomGameEventManager:Send_ServerToAllClients("update_bonus_gold_display", { team = BONUSTEAM, gpm = GOLDBONUS*60 })
        else
            goldBonusActive = false
            CustomGameEventManager:Send_ServerToAllClients("hide_bonus_gold_display", { message = "none"})
        end
      return 1
   end
})

function GrantBonusGold(team, amount)
    for x=0,DOTA_MAX_TEAM do
        local pID = PlayerResource:GetNthPlayerIDOnTeam(team,x)
        if PlayerResource:IsValidPlayerID(pID) and PlayerResource:GetConnectionState(pID) == 2 then
            local g = PlayerResource:GetUnreliableGold(pID) + amount
            PlayerResource:SetGold(pID, g, false)
        end
    end
end