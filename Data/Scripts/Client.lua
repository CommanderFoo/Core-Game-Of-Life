local YOOTIL = require(script:GetCustomProperty("YOOTIL"))

local ui_grid = script:GetCustomProperty("ui_grid"):WaitForObject()
local ui_cell = script:GetCustomProperty("ui_cell")
local count = script:GetCustomProperty("count"):WaitForObject()

local grid = {}

local size = 14
local cols = math.floor(ui_grid.width / size)
local rows = math.floor(ui_grid.height / size)
local tweens = {}
local generation = 1
local tween_in_time = .08
local tween_out_time = .08
local refresh_speed = 0.05

for c = 1, cols do
	grid[c] = {}

	for r = 1, rows do
		local obj = World.SpawnAsset(ui_cell, { parent = ui_grid })

		obj.width = size
		obj.height = size

		obj.x = c * size
		obj.y = r * size

		local rnd = math.floor(math.random(2))
		local state = 0

		if(rnd > 1) then
			state = 1
			obj:SetColor(Color.WHITE)
		else
			obj:SetColor(Color.BLACK)
		end

		-- if(c == 2 and (r == 2 or r == 3 or r == 4)) then
		-- 	obj:SetColor(Color.WHITE)
		-- 	state = 1	
		-- end

		obj.name = tostring(c) .. " " .. tostring(r)

		grid[c][r] = {
			
			obj = obj,
			state = state

		}

	end
end

local function is_alive(c, r)
	if(c < 1 or c > cols or r < 1 or r > rows) then
		return 0
	end

	return grid[c][r].state
end

function Tick(dt)
	local a = 0
	for c = 1, cols do
		for r = 1, rows do
			local total = 0
			
			total = total + is_alive(c - 1, r - 1)
			total = total + is_alive(c, r - 1)
			total = total + is_alive(c + 1, r - 1)

			total = total + is_alive(c - 1, r)
			total = total + is_alive(c + 1, r)

			total = total + is_alive(c - 1, r + 1)
			total = total + is_alive(c, r + 1)
			total = total + is_alive(c + 1, r + 1)

			if grid[c][r].state == 0 and total == 3 then
				grid[c][r].next_state = 1
			elseif(grid[c][r].state == 1 and (total < 2 or total > 3)) then
				grid[c][r].next_state = 0
			else
				grid[c][r].next_state = grid[c][r].state
			end

			a = a + 1
		end
	end

	Task.Wait(refresh_speed)

	for c = 1, cols do
		for r = 1, rows do
			local col = grid[c][r].obj:GetColor()

			if(grid[c][r].next_state == 0 and grid[c][r].state ~= grid[c][r].next_state) then
				local t = YOOTIL.Tween:new(tween_in_time, { r = col.r, g = col.g, b = col.b }, { r = 0, g = 0, b = 0 })

				t:on_change(function(v)
					col.r = v.r
					col.g = v.g
					col.b = v.b

					grid[c][r].obj:SetColor(col)
				end)

				t:on_complete(function()
					t = nil
				end)

				grid[c][r].state = grid[c][r].next_state

				tweens[tostring(c) .. "_" .. tostring(r)] = t
			elseif(grid[c][r].state ~= grid[c][r].next_state) then
				local t = YOOTIL.Tween:new(tween_out_time, { r = col.r, g = col.g, b = col.b }, { r = 1, g = 1, b = 1 })

				t:on_change(function(v)
					col.r = v.r
					col.g = v.g
					col.b = v.b

					grid[c][r].obj:SetColor(col)
				end)

				t:on_complete(function()
					t = nil
				end)

				grid[c][r].state = grid[c][r].next_state

				tweens[tostring(c) .. "_" .. tostring(r)] = t
			end
		end
	end

	for k, tween in pairs(tweens) do
		if(tween ~= nil) then
			tween:tween(dt)
		end
	end

	generation = generation + 1

	count.text = tostring(generation)
end