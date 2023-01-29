pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
--variables

function _init()
	player={
		sp=1,
		x=59,
		y=59,
		w=8,
		h=8,
		flp=false,
		dx=0,
		dy=0,
		max_dx=2,
		max_dy=3,
		acc=0.5,
		boost=4,
		anim=0,
		running=false,
		jumping=false,
		falling=false,
		sliding=false,
		landed=false
	}
	
	gravity=0.3
	friction=0.85
	
	--simple camera
	cam_x=0
	
	--map limits
	map_start=0
	map_end=1024 -- 8 * 128
end
-->8
--update and draw
function _update()
	player_update()
	player_animate()
	
	--simple camera
	cam_x=player.x-64+player.w/2
	if cam_x<map_start then
		cam_x=map_start
	end
	if cam_x>map_end-128 then
		cam_x=map_end-128
	end
	camera(cam_x,0)
end

function _draw()
	cls()
	map(0,0)
	spr(player.sp,player.x,player.y,1,1,player.flp)
end
-->8
--collisions

function collide_map(obj,aim,flag)
	--obj = table needs x,y,w,h
	--aim = left,right,up,down
	
	local x=obj.x 
	local y=obj.y
	local w=obj.w 
	local h=obj.h
	
	local x1=0 
	local y1=0
	local x2=0 
	local y2=0
	
	if aim=="left" then
		x1=x-1   y1=y
		x2=x		   y2=y+h-1
	
	elseif aim=="right" then
		x1=x+w   y1=y
		x2=x+w+1	y2=y+h-1
		
	elseif aim=="up" then
		x1=x+1   y1=y-1
		x2=x+w-1	y2=y
	
	elseif aim=="down" then
		x1=x     y1=y+h
		x2=x+w  	y2=y+h
	
	end	
	
	--pixels to tiles
	
	x1/=8				y1/=8
	x2/=8				y2/=8
	
	if fget(mget(x1,y1), flag)
	or fget(mget(x1,y2), flag)
	or fget(mget(x2,y1), flag)
	or fget(mget(x2,y2), flag) then
		return true
	else
		return false
	end	
end
-->8
--player

function player_update()
	--physics
	player.dy+=gravity
	player.dx*=friction
	
	--controls
	if btn(⬅️) then
		player.dx-=player.acc
		player.running=true
		player.flp=true
	end
	if btn(➡️) then
		player.dx+=player.acc
		player.running=true
		player.flp=false
	end
	
	--slide
	if player.running
	and not btn(⬅️)
	and not btn(➡️)
	and not player.falling
	and not player.jumping then
		player.running=false
		player.sliding=true
	end
	
	--jump
	if btnp(❎)
	and player.landed then
		player.dy-=player.boost
		player.landed=false
	end
	
	--check collision up and down
	if player.dy>0 then
		player.falling=true
		player.landed=false
		player.jumping=false
		
		player.dy=limit_speed(player.dy,player.max_dy)
		
		if collide_map(player,"down",0) then
			player.landed=true
			player.falling=false
			player.dy=0
			player.y-=(player.y+player.h)%8
		end
	elseif player.dy<0 then
		player.jumping=true
		if collide_map(player,"up",1) then
			player.dy=0
		end	
	end
	
	--check collision left and right
	if player.dx<0 then
	
		player.dx=limit_speed(player.dx,player.max_dx)	
	
		if collide_map(player,"left",1) then
			player.dx=0
		end
	elseif player.dx>0 then
	
		player.dx=limit_speed(player.dx,player.max_dx)
	
		if collide_map(player,"right",1) then
			player.dx=0
		end	
	end
	
	--stop sliding
	if player.sliding then
		if abs(player.dx)<.2
		or player.running then
			player.dx=0
			player.sliding=false
		end
	end
	
	player.x+=player.dx
	player.y+=player.dy	
	
	--limit player to map
	if player.x<map_start then
		player.x=map_start
	end
	if player.x>map_end-player.w then
		player.x=map_end-player.w
	end
	
end

function player_animate()
	if player.jumping then
		player.sp=7
	elseif player.falling then
		player.sp=8
	elseif player.sliding then
		player.sp=9
	elseif player.running then
		if time()-player.anim>.1 then
			player.anim=time()
			player.sp+=1
			if player.sp>6 then
				player.sp=3
			end
		end
	else --player idle
		if time()-player.anim>.3 then
			player.anim=time()
			player.sp+=1
			if player.sp>2 then
				player.sp=1
			end
		end
	end
end

function limit_speed(num,maximum)
	return mid(-maximum,num,maximum)
end
__gfx__
00000000004444400044444000044444080444440004444400044444000444448004444400000000000000000000000000000000000000000000000000000000
00000000008888800088888008888888808888888008888880888888008888880888888804444400000000000000000000000000000000000000000000000000
0070070008f71f1008f71f10800ff71f000ff71f088ff71f080ff71f080ff71f000ff71f08888800000000000000000000000000000000000000000000000000
0007700008fffff008fffef0000ffffe000ffffe000ffffe000ffffe800ffffe000ffffe8f71f100000000000000000000000000000000000000000000000000
0007700000088000008888000f8880000f8880000f8880000f88800000888000000088808fffef00000000000000000000000000000000000000000000000000
00700700008888000f0880f0000880000008800000088000000880000f0880000000880f008888f0000000000000000000000000000000000000000000000000
000000000f0890f0000890000880900000890000099800000098000000980000000008900f088900000000000000000000000000000000000000000000000000
00000000008009000080090000009000008900000008000000980000098000000000008900008899000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00bbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000
3bbb333bbbbb3b33bbbbbbb33b333bbb0bbbb3b3bbb3bbb000000000000000000000000000000000000000000000000000000000000000000000000000000000
3b3344433bbb33443bbbb334334443b3b3b334343b3433bb00000000000000000000000000000000000000000000000000000000000000000000000000000000
4b34444443b3444443bb34444444443bbbb34444434443bb00000000000000000000000000000000000000000000000000000000000000000000000000000000
434442444434449443b349444494443bbb344494444f443b00000000000000000000000000000000000000000000000000000000000000000000000000000000
444444444444444443b34444444444b3b3444444444443bb00000000000000000000000000000000000000000000000000000000000000000000000000000000
444444d44d4474444434445444445434bb344f444544443b00000000000000000000000000000000000000000000000000000000000000000000000000000000
44944444444444444444444444444444334444444444444300000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444444444494000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444449444f444444444e4444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444494444f444444444454444444744000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444422444444444444444774000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4744444454442e24d6444444f4447644000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444446444444224d664444444776444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444dd4449444474454000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44e44444464444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333334444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbb3bbbbbbbb3bb9999499999999499000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbb3bbbbbbbb3bbb9994999999994999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333334444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b3bbbb3bbb3bbbbb9499994999499999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb3bbb3bbbb3bbbb9949994999949999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333334444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bb300000000000049940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bb300003bb3000049940000499400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0033b300003bb3000044940000499400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bb300003bb3000049940000499400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bb300003333000049940000444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bb300003bb3000049940000499400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003b3300003bb3000049440000499400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bb300003bb3000049940000499400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bb300003bb3000049940000499400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003030303030300000000000000000000030303030000000000000000000000000101010100000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
7071000000000000000000000000000000000000000000000000000000000000000000000000606160000000000000000000000000000000000000000000006060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7171000000000000000000000000000000000000000000000000000000000000000000000000700070000000000000000000000000000000000000000000606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7071000000000000000000000000000000000000000000000000000000000000000000000000606160000000000000000000000000000000000000000060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7170000000000000000000000000000000000000000000000000000000000000000000000000700070000000000000000000000000000000000000006060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7071000000000000000000000000000000000000000000000000000000000000000000000000606160000000000000000000000000000000000000606000000000000000000000000000000000000000000000000000000000000000000000000000004440424341450000000000000000000000000000000000000000000000
7170000000000000000000000000000000000000000000000000000000000000000000000000700070000000000000000000000000000000000060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7170000000000000000000000000000000000000000000000000000000000000000000000000606160000000000000000000000000000000006060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7071000000000000000000000000000000000000000000000000000000000000000000000000700070000000000000000000000000000000606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000444340450000000000000000000000000000000000000000000000
7171000000000000000060000000000000000000000000000000000000000000000000000000606160000000000000000000000000000060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000505050504500000000000000000000000000000000000000000000
7170000000000000000071000000000000000000000000000000000000000000000000000000700070000000000000000000000000006060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050505040450000000000000000000000000000000000000000
7071006262000000616061606100000000000000000000000000000000000000000000000000606160000000000000000000000000606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005050500000000000000000000000000000000000000000
7171007372000000007000710000000000000000000000000000000000006060000000000000700070000000000060600000000060600000000000000000606000616100006161000000616161006060000000006161000000000061610060600000000000000000000000000000606000000000000000000000000000006060
7170004445000000007100700000000000000000000000000000000000007171000000000000606160000000000071710000006060000000000000000000717100000000000000000000000000007171000000000000000000000000000071710000000000000000000000000000717100000000000000000000000000007171
7071445250424500007000710000710000000000000000000000000000007171000000000000700070000000000071710000606000000000000000000000717100000000000000000000000000007171000000000000000000000000000071710000000000000000000000000000717100000000000000000000000000007171
4041505053505040434041404042404340414042404143404040424041434041404140424041434040404240414340414041404240414340404042404143404140414042404143404040424041434041404140424041434040404240414340414041404240414340404042404143404140414042404143404040424041434041
5051505050505052505053505150505250505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050
