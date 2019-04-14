//"use strict";
var votepanel = $("#VoteKickWindow");

function OnVoteKick(data) {
    $("#VoteKickInitiator").text = data.initiator;
    $("#VoteKickVictim").text = data.victim;
    votepanel.visible = true;
}

function OnVoteKickTimeout() {
    votepanel.visible = false;
}

function OnVoteKickCloseButtonPressed() {
    votepanel.visible = false;
}

function OnVoteKickYesButtonPressed() {
    votepanel.visible = false;
    var player = Players.GetLocalPlayer();
    GameEvents.SendCustomGameEventToServer("cast_vote", { playerId: player, result: "1" } );
}

function OnVoteKickNoButtonPressed() {
    votepanel.visible = false;
    var player = Players.GetLocalPlayer();
    GameEvents.SendCustomGameEventToServer("cast_vote", { playerId: player, result: "0" } );
}

(function()
{
    GameEvents.Subscribe("display_vote_kick", OnVoteKick);
    GameEvents.Subscribe("hide_vote_kick", OnVoteKickTimeout);
})();