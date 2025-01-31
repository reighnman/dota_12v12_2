var PlayerPanels = [];
var TeamPanels = [];
var darknessEndTime = -Number.MAX_VALUE;

var teamColors = {};
teamColors[DOTATeam_t.DOTA_TEAM_GOODGUYS] = "#008000";
teamColors[DOTATeam_t.DOTA_TEAM_BADGUYS] = "#FF0000";

function Snippet_TopBarPlayerSlot(playerId) {
	if (PlayerPanels[playerId] != null) return PlayerPanels[playerId];
	var team = Players.GetTeam(playerId)
	if (team === DOTA_TEAM_SPECTATOR) return PlayerPanels[playerId];

	var teamPanel = Snippet_DotaTeamBar(team).FindChildTraverse('TopBarPlayersContainer');
	var panel = $.CreatePanel('Panel', teamPanel, '');
	panel.BLoadLayoutSnippet('TopBarPlayerSlot');
	panel.playerId = playerId;
	panel.FindChildTraverse('HeroImage').SetPanelEvent('onactivate', function() {
		Players.PlayerPortraitClicked(playerId, GameUI.IsControlDown(), GameUI.IsAltDown());
	});
	var TopBarUltIndicator = panel.FindChildTraverse('TopBarUltIndicator');
	TopBarUltIndicator.SetPanelEvent('onmouseover', function() {
		if (panel.ultimateCooldown != null && panel.ultimateCooldown > 0) {
			$.DispatchEvent('UIShowTextTooltip', TopBarUltIndicator, panel.ultimateCooldown);
		}
		//$.DispatchEvent("UIShowTopBarUltimateTooltip ", panel, playerId);
	});
	panel.FindChildTraverse('TopBarUltIndicator').SetPanelEvent('onmouseout', function() {
		$.DispatchEvent('UIHideTextTooltip', panel);
		//$.DispatchEvent("DOTAHideTopBarUltimateTooltip", panel);
	});
	panel.Resort = function() {
		SortPanelChildren(teamPanel, dynamicSort('-playerId'), function(child, child2) {
			return child.playerId > child2.playerId;
		});
	};
	panel.Resort();
	PlayerPanels[playerId] = panel;
	return panel;
}

function Snippet_TopBarPlayerSlot_Update(panel) {
	var playerId = panel.playerId;
	var playerInfo = Game.GetPlayerInfo(playerId);
	var connectionState = playerInfo.player_connection_state;
	panel.visible = connectionState != DOTAConnectionState_t.DOTA_CONNECTION_STATE_ABANDONED;
	if (!panel.visible) return;

	var respawnSeconds = playerInfo.player_respawn_seconds;
	var heroEnt = playerInfo.player_selected_hero_entity_index;
	var isAlly = playerInfo.player_team_id === Players.GetTeam(Game.GetLocalPlayerID());
	panel.SetDialogVariableInt('respawn_seconds', respawnSeconds + 1);
	panel.SetHasClass('Dead', respawnSeconds >= 0);
	panel.SetHasClass('Disconnected', connectionState === DOTAConnectionState_t.DOTA_CONNECTION_STATE_DISCONNECTED);
	panel.FindChildTraverse('HeroImage').heroname = playerInfo.player_selected_hero;
	panel.FindChildTraverse('PlayerColor').style.backgroundColor = GetHEXPlayerColor(playerId);
	var ultStateOrTime = isAlly ? Game.GetPlayerUltimateStateOrTime(playerId) : PlayerUltimateStateOrTime_t.PLAYER_ULTIMATE_STATE_HIDDEN;
	panel.SetHasClass('UltLearned', ultStateOrTime !== PlayerUltimateStateOrTime_t.PLAYER_ULTIMATE_STATE_NOT_LEVELED);
	panel.SetHasClass('UltReady', ultStateOrTime === PlayerUltimateStateOrTime_t.PLAYER_ULTIMATE_STATE_READY);
	panel.SetHasClass('UltReadyNoMana', ultStateOrTime === PlayerUltimateStateOrTime_t.PLAYER_ULTIMATE_STATE_NO_MANA);
	panel.SetHasClass('UltOnCooldown', ultStateOrTime > 0);
	panel.FindChildTraverse('HealthBar').value = Entities.GetHealthPercent(heroEnt) / 100;
	panel.FindChildTraverse('ManaBar').value = Entities.GetMana(heroEnt) / Entities.GetMaxMana(heroEnt);
	panel.ultimateCooldown = ultStateOrTime;
	panel.SetHasClass("BuybackReady", Players.CanPlayerBuyback(playerId));
	var lastBuybackTime = Players.GetLastBuybackTime(playerId)
	panel.SetHasClass("BuybackUsed", lastBuybackTime != 0 && Game.GetGameTime() - lastBuybackTime < 10)
	if (playerInfo.player_team_id !== DOTA_TEAM_SPECTATOR && playerInfo.player_team_id !== panel.GetParent().team && teamColors[playerInfo.player_team_id] != null) {
		panel.SetParent(Snippet_DotaTeamBar(playerInfo.player_team_id).FindChildTraverse('TopBarPlayersContainer'));
	}
}

function Snippet_DotaTeamBar(team) {
	if (TeamPanels[team] == null) {
		var isRight = team % 2 !== 0;
		var rootPanel = $(isRight ? '#TopBarRightPlayers' : '#TopBarLeftPlayers');
		var panel = $.CreatePanel('Panel', rootPanel, '');
		panel.BLoadLayoutSnippet('DotaTeamBar');
		panel.team = team;
		panel.FindChildTraverse('TopBarScore').style.textShadow = '0 0 7px ' + teamColors[team];
		TeamPanels[team] = panel;
		SortPanelChildren(rootPanel, dynamicSort('team'), function(child, child2) {
			return child.team < child2.team;
		});
	}
	return TeamPanels[team];
}

function Snippet_DotaTeamBar_Update(panel) {
	var team = panel.team
	panel.SetHasClass("EnemyTeam", team != Players.GetTeam(Game.GetLocalPlayerID()));
	var teamDetails = Game.GetTeamDetails(team);
	panel.SetDialogVariableInt("team_score", teamDetails.team_score);
}

function Update() {
	$.Schedule(0.1, Update);
	var rawTime = Game.GetDOTATime(false, true);
	var time = Math.abs(rawTime);
	var isNSNight = rawTime < darknessEndTime;
	var timeThisDayLasts = time - (Math.floor(time / 600) * 600);
	var isDayTime = !isNSNight && timeThisDayLasts <= 300;
	var context = $.GetContextPanel();

	context.SetHasClass('DayTime', isDayTime);
	context.SetHasClass('NightTime', !isDayTime);
	context.SetDialogVariable('time_of_day', secondsToMS(time, true));
	context.SetDialogVariable('time_until', secondsToMS((isDayTime ? 300 : 600) - timeThisDayLasts, true));
	context.SetDialogVariable('day_phase', $.Localize(isDayTime ? 'DOTA_HUD_Night' : 'DOTA_HUD_Day'));

	$("#DayTime").visible = isDayTime;
	$("#NightTime").visible = !isNSNight && !isDayTime;
	$("#NightstalkerNight").visible = isNSNight;
	$.Each(Game.GetAllPlayerIDs(), function(pid) {
		Snippet_TopBarPlayerSlot_Update(Snippet_TopBarPlayerSlot(pid));
	})
	for (var i in TeamPanels) {
		Snippet_DotaTeamBar_Update(TeamPanels[i]);
	}

	context.SetHasClass("AltPressed", GameUI.IsAltDown())
}

function TimerClick()
{
	if (GameUI.IsAltDown())
	{
		GameEvents.SendCustomGameEventToServer( "OnTimerClick", {id: Game.GetLocalPlayerID(),time: $("#GameTime").text});
	}
}

(function() {
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_TIMEOFDAY, false);
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_HEROES, false);
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_BAR_BACKGROUND, false);
	FindDotaHudElement("topbar").visible = true;
	GameEvents.Subscribe("time_nightstalker_darkness", (function(data) {
		darknessEndTime = Game.GetDOTATime(false, false) + data.duration
	}))
	$("#TopBarLeftPlayers").RemoveAndDeleteChildren();
	$("#TopBarRightPlayers").RemoveAndDeleteChildren(); // reload support
	Snippet_DotaTeamBar(DOTATeam_t.DOTA_TEAM_GOODGUYS);
	Snippet_DotaTeamBar(DOTATeam_t.DOTA_TEAM_BADGUYS);
	Update();
})()