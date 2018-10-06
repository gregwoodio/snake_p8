pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

x = 3
y = 7
up = 0
right = 1
down = 2
right = 3
dir = right
inc = 8 		-- how far the snake steps every time
level = 8 		-- difficulty level, lower is harder
tick = 0		-- current time, used for setting difficulty
game_active = true
sound_played = false
sprite_width = 8
score = 0
snake = {
	{x = x, y = y, dir = dir},
	{x = x - 1, y = y, dir = dir},
	{x = x - 2, y = y, dir = dir}
}
apple = {
	x = 10,
	y = 10
}

function _init()
	music(0)
end

function get_length (seq)
	len = 0
	for index, value in pairs(seq) do
		len = len + 1
	end
	return len
end

function place_apple()
	randx = flr(rnd(16))
	randy = flr(rnd(16))

	for index, pos in pairs(snake) do
		if (pos.x == randx and pos.y == randy) then
			place_apple()
		end
	end

	apple = {
		x = randx,
		y = randy
	}
end

function _update()
	-- set direction
	if (game_active) then
		if (btnp(0) and dir != right) then 
			dir = left
		elseif (btnp(1) and dir != left) then 
			dir = right
		elseif (btnp(2) and dir != down) then 
			dir = up
		elseif (btnp(3) and dir != up) then 
			dir = down
		end
	end
	-- update x and y
	if (tick == 0 and game_active) then
		if (dir == up) then
			y -= 1
		elseif (dir == down) then
			y += 1
		elseif (dir == right) then
			x += 1 
		elseif (dir == left) then
			x -= 1
		end

		-- check bounds, + sprite width
		if (x < 0) then
			game_active = false
			x = 0
		elseif (x > 15) then
			game_active = false
			x = 15
		elseif (y < 0) then
			game_active = false
			y = 0
		elseif (y > 15) then
			game_active = false
			y = 15
		else 
			-- make sure we haven't hit the tail
			for index, pos in pairs(snake) do
				if (pos.x == x and pos.y == y) then
					game_active = false
				end
			end
		end	

		-- check if we've got the apple
		if (x == apple.x and y == apple.y) then
			place_apple()
			score += 1
			sfx(3)
			if (score % 5 == 0) then
				level -= 1
				if (level < 0) then level = 0 end
			end
			len = get_length(snake)
			snake_tail = snake[len]
			add(snake, snake_tail)
		end

		if (game_active) then
			-- add new position to snake. Is there an insert method?
			len = get_length(snake)
			
			new_snake = {
				{x = x, y = y, dir = dir}			
			}
			for index, pos in pairs(snake) do
				add(new_snake, pos)
				if (index + 1 == len) then
					add(new_snake, nil)
					break
				end
			end

			snake = new_snake
			new_snake = nil
		end
	end

	-- play dying sound, stop music
	if (game_active == false and sound_played == false) then
		sfx(4)
		music(-1)
		sound_played = true
	end

	tick = (tick + 1) % level
end

function _draw()
 -- draw background
	rectfill(0, 0, 127, 127, 1)
	dead = 0
	if (game_active == false) then
		dead = 2
	end
	
	-- draw sprite
	for index, pos in pairs(snake) do
		-- sprite will usually be the body
		sprite = 5

		-- sprite will be the head on the first iteration, and with dead face if game is over
		if (index == 1) then 
			sprite = 1 + dead
		end

		if (pos.dir == up) then
			spr(sprite, pos.x * inc, pos.y * inc)
		elseif (pos.dir == down) then
			spr(sprite, pos.x * inc, pos.y * inc, 1, 1, false, true)
		elseif (pos.dir == right) then
			spr(sprite + 1, pos.x * inc, pos.y * inc)
		elseif (pos.dir == left) then
			spr(sprite + 1, pos.x * inc, pos.y * inc, 1, 1, true)
		end
	end

	-- draw apple
	spr(0, apple.x * inc, apple.y * inc)
end	
__gfx__
00003300033333300333333003333330033333300333333003333330044444400444444000000000000000000000000000000000000000000000000000000000
08883380371331733333377333133133333331333333333333b33b33444444444454454400000000000000000000000000000000000000000000000000000000
88838888377337733333371331333313333333133b3333b33b33b333454444544544544400000000000000000000000000000000000000000000000000000000
88888e883333333333333333333333333333333333bbbb333b33b333445555444544544400000000000000000000000000000000000000000000000000000000
8888888833333333333333333333333333333333333333333b33b333444444444544544400000000000000000000000000000000000000000000000000000000
08888880333333333333371333333333333333133b3333b33b33b333454444544544544400000000000000000000000000000000000000000000000000000000
088888803333333333333773333333333333313333bbbb3333b33b33445555444454454400000000000000000000000000000000000000000000000000000000
00888800033333300333333003333330033333300333333003333330044444400444444000000000000000000000000000000000000000000000000000000000
__sfx__
000400000405004050040500405000000000000000001b0016050160501605016050000000000000000000000c0500c0500c0500c050000000000000000000000905009050090500905000000186001960000000
0004000000000000000000000000000000000000000000000000000000075000750007500075000650000000337503475033750327500650006500065000650032750347503375032750025001e5002050023500
0104000001770017500000000000000000000000000000000e6500c610000000000000000000000000000000017700175000000016000177001750000000000000000000000d6500a61004600000000000000000
000400001605015050160501b05022050390003f0000a000070001405015050180501c0501d0501f0501f0501f0501e0501d050130500d050050500105023000240002500026000280002b0002f0003500039000
000300002d0502b0502a0502805024050210501d050180501105008050010501e6001d6001b6001f100186000f6000e6000e6000e6000e6000e6000e6000e6000e6000e6000e6000e6000e6000d6000d6000d600
__music__
01 00024344
02 00020144
00 40424344
02 40414244
02 41424344

