function load()

	love.filesystem.require("tables/nice.lua") -- start table

	love.filesystem.require("notes/sfxr.lua") -- music notes

	-- colors...
	darkGrey = love.graphics.newColor(51,51,51)
	text = love.graphics.newColor(200,200,200)
	white = love.graphics.newColor(255,255,255)
	lightGrey = love.graphics.newColor(100,100,100)
	grey = love.graphics.newColor(68,68,68)

	love.graphics.setBackgroundColor(darkGrey)

	curRow = 1 -- currently played row

	dtSum = 0 -- dtSum counts time
	dtLimit = .25 -- dtLimit controls speed

	love.audio.setChannels(16) -- cannels! yay! I bet this won't work!
	love.audio.setVolume(.3) -- games have too loud a volume always :(
	volume = .3 -- since there seems to be no getVolume()
	cursorX = 0 -- cursor x position
	cursorY = 0 -- cursor y position
	cursorField = {} -- the field currently 'inhabited' by the cursor

	help = false -- controls help showing
	helpUsed = false -- controls help help showing
	love.graphics.setFont(love.default_font)
end

function update(dt)
	dtSum = dtSum + dt -- stack the time

	cursorField = updateCursorField()

	if dtSum > dtLimit then -- if enough time is stacked...
		dtSum = dtSum - dtLimit -- 'clear' dtSum
		for i, v in pairs(table) do -- for each column in table...
			if v[curRow] > 0 then -- if the row's volume is > 0...
				notes[i]:setVolume(v[curRow]) -- apply current row's volume
				love.audio.play(notes[i]) -- play it
			end
		end
		if curRow == 16 then curRow = 1 else curRow = curRow + 1 end -- next row
	end
end

function draw()
	for i, v in pairs(table) do -- for each column in table...
		for j, w in pairs(v) do -- for each row in table...
			if j == curRow or (cursorField[1] == i and cursorField[2] == j) then -- if current row is played or cursor is in field...
				love.graphics.setColor(lightGrey) -- set color to background rectangle light grey
			else
				love.graphics.setColor(grey) -- set color to background rectangle grey
			end
			love.graphics.rectangle(0, 32*(j-1)+8, 32*(i-1)+8, 24, 24) -- draw background rectangle
			if w > 0 then-- if field is > 0...
				love.graphics.setColor(white) -- set color to foreground rectangle white
				love.graphics.rectangle(0, 32*(j-1)+8, 32*(i-1)+8+24-24*w, 24, 24*w) -- draw note rectangle
			end
		end
	end
	-- help and help help drawing
	love.graphics.setColor(text) -- set color to help text black
	if helpUsed == false then love.graphics.draw("help/hide this: hold H", 16, 26) end -- draw help help the first 4 seconds
	if help then love.graphics.draw("enable/disable: Mouse Button (Left)\nincrease/decrease: Mouse Wheel Up/Down\nclear: Backspace\nmaster volume: +/-\nquit: Q, Esc",16,26) end
end

function updateCursorField()
	cursorField = {} -- set to nil, in case we find nothing
	cursorX = love.mouse.getX() -- update cursor x value
	cursorY = love.mouse.getY() -- update cursor y value
	for i, v in pairs(table) do -- for each column.
		if cursorY >= 32*(i-1)+8 and cursorY <= 32*i then -- if cursor y position is in the column...
			for j, w in pairs(v) do -- for each row
				if cursorX >= 32*(j-1)+8 and cursorX <= 32*j then -- if cursor x position is in the row...
					return {i, j}
				end
			end
		end
	end
	return {} -- the 'currently hovered field' if there is none
end

function mousepressed(x,y,button)
	if cursorField[1] ~= nil then -- if there is a 'currently hovered field'
		local a, b = cursorField[1], cursorField[2] -- less type = good
		if button == love.mouse_left then -- on left click...
			if table[a][b] > 0 then -- if field is active...
				table[a][b] = 0 -- disable it
			else
				table[a][b] = 1 -- enable it 100%
			end
		elseif button == love.mouse_wheelup then -- on wheel up...
			if table[a][b] < 1 then -- if field is less than 100% active...
				table[a][b] = table[a][b] + .25	-- add a quarter of power to it
			end
		elseif button == love.mouse_wheeldown then -- on wheel down...
			if table[a][b] > 0 then -- if field is active...
				table[a][b] = table[a][b] - .25 -- reduce it's power by 1/4
			end
		end
	end
end

function keypressed(key)
	if key == love.key_escape or key == love.key_q then
		love.system.exit()
	elseif key == love.key_backspace then
		love.filesystem.include("tables/empty.lua")
	elseif key == love.key_h then
		help = true
		helpUsed = true
	elseif (key == love.key_plus or key == love.key_kp_plus) and volume < .91 then
		volume = volume + .1
		love.audio.setVolume(volume)
		print(volume)
	elseif (key == love.key_minus or key == love.key_kp_minus) and volume > 0.01 then
		volume = volume - .1
		love.audio.setVolume(volume)
		print(volume)
	end
end

function keyreleased(key)
	if key == love.key_h then
		help = false
	end
end
