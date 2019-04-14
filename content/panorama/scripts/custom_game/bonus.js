var bonuspanel = $("#BonusWindow");

function UpdateBonusGoldDisplay(data)
{
    var bonustext = data.team;
    bonustext = bonustext + " +";
    bonustext = bonustext + data.gpm;
    bonustext = bonustext + " GPM"
    $("#BonusGoldLabel").text = bonustext
    bonuspanel.visible = true;
}

function HideBonusGoldDisplay()
{
    bonuspanel.visible = false;
}

(function()
{
    GameEvents.Subscribe("update_bonus_gold_display", UpdateBonusGoldDisplay);
    GameEvents.Subscribe("hide_bonus_gold_display", HideBonusGoldDisplay);
})();