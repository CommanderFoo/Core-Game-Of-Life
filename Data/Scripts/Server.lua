Game.playerJoinedEvent:Connect(function(player)
	player.isMovementEnabled = false
	player.canMount = false
end)