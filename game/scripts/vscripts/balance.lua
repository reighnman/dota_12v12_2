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
    endTime = 1,
    callback = function()
        GOODGUYSQTY = GetActivePlayerCountForTeam(DOTA_TEAM_GOODGUYS)
        BADGUYSQTY = GetActivePlayerCountForTeam(DOTA_TEAM_BADGUYS)
      return 1
    end
})

--This shouldn't be here but we can organize later
Timers:CreateTimer("timerGoldBonus", {
    endTime = 3, --begin roughly 5min in
    callback = function()
        if (GOODGUYSQTY < BADGUYSQTY) then
            local multi = BADGUYSQTY - GOODGUYSQTY
            GOLDBONUS = multi * GOLD_BONUS_PP_PS
            GrantBonusGold(DOTA_TEAM_GOODGUYS, GOLDBONUS)
            goldBonusActive = true
            BONUSTEAM = "RADIANT"
        elseif (BADGUYSQTY < GOODGUYSQTY) then
            local multi = GOODGUYSQTY - BADGUYSQTY
            GOLDBONUS = multi * GOLD_BONUS_PP_PS
            GrantBonusGold(DOTA_TEAM_BADGUYS, GOLDBONUS)
            goldBonusActive = true
            BONUSTEAM = "DIRE"
        else
            goldBonusActive = false
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

--Check status
ChatCommand:LinkCommand("-goldbonus", "GoldBonusStatus")
function GoldBonusStatus(keys)
    if (goldBonusActive) then
        GameRules:SendCustomMessage("<B><font color='#FFFF00'>Gold bonus is in effect for " .. BONUSTEAM .. " (" .. GOLDBONUS * 60 .. "GPM)", 0, 0)
    else
        GameRules:SendCustomMessage("<B><font color='#FFFF00'>Gold bonus is not active.", 0, 0)
    end
  end