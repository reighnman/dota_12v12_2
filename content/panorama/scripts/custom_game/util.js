var DOTA_TEAM_SPECTATOR = 1;

function GetDotaHud() {
	var p = $.GetContextPanel();
	while (p !== null && p.id !== 'Hud') {
		p = p.GetParent();
	}
	if (p === null) {
		throw new HudNotFoundException('Could not find Hud root as parent of panel with id: ' + $.GetContextPanel().id);
	} else {
		return p;
	}
}

function SubscribeToNetTableKey(tableName, key, callback) {
    var immediateValue = CustomNetTables.GetTableValue(tableName, key) || {};
    if (immediateValue != null) callback(immediateValue);
    CustomNetTables.SubscribeNetTableListener(tableName, function (_tableName, currentKey, value) {
        if (currentKey === key && value != null) callback(value);
    });
}

function FindDotaHudElement(id) {
	return GetDotaHud().FindChildTraverse(id);
}

function GetHEXPlayerColor(playerId) {
	var playerColor = Players.GetPlayerColor(playerId).toString(16);
	return playerColor == null ? '#000000' : ('#' + playerColor.substring(6, 8) + playerColor.substring(4, 6) + playerColor.substring(2, 4) + playerColor.substring(0, 2));
}

function secondsToMS(seconds, bTwoChars) {
	var sec_num = parseInt(seconds, 10);
	var minutes = Math.floor(sec_num / 60);
	var seconds = Math.floor(sec_num - minutes * 60);

	if (bTwoChars && minutes < 10)
		minutes = '0' + minutes;
	if (seconds < 10)
		seconds = '0' + seconds;
	return minutes + ':' + seconds;
}

function dynamicSort(property) {
	var sortOrder = 1;
	if (property[0] === "-") {
		sortOrder = -1;
		property = property.substr(1);
	}
	return function(a, b) {
		var result = (a[property] < b[property]) ? -1 : (a[property] > b[property]) ? 1 : 0;
		return result * sortOrder;
	}
}

function SortPanelChildren(panel, sortFunc, compareFunc) {
	var tlc = panel.Children().sort(sortFunc)
	$.Each(tlc, function(child) {
		for (var k in tlc) {
			var child2 = tlc[k]
			if (child != child2 && compareFunc(child, child2)) {
				panel.MoveChildBefore(child, child2)
				break;
			}
		}
	});
}
