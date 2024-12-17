//custom player functions
function setOnGround( _val = true )
{
	if _val = true
		{
			onGround = true
			coyoteHangTimer = coyoteHangFrames
		}	else	{
			onGround = false
			myFloorPlat = noone
			coyoteHangTimer = 0
		}
}
function checkForSemiSolidPlat( _x, _y )
{
	//create a return variable
	var _rtrn = noone
	
	//must not be moving upward, and check for normal collision
	if yspd >= 0 && place_meeting( _x, _y, oSemiSolidWall )
	{
		//create ds list to store colliding instances of oSemiSolidWall
		var _list = ds_list_create()
		var _listSize = instance_place_list( _x, _y, oSemiSolidWall, _list, false)
		
		//loop through the coliding instances and only return one if its top is below the player
		for (var i = 0; i <_listSize; i++ )
		{
			var _listInst = _list[| i]
			if _listInst != forgetSemiSolid && floor( bbox_bottom) <= ceil( _listInst.bbox_top - _listInst.yspd )
			{
				//return the id of a semisolid platform
				_rtrn = _listInst
				//exit loop early 
				i = _listSize
			}
		}
		//destroy ds list to avoid memory leak
		ds_list_destroy( _list )
	}
	//return the variable
	return _rtrn
}

//controlSetup
controlsSetup()

depth = -3

//sprites
idleSpr = sPlayerIdle
walkSpr = sPlayerWalk
runSpr = sPlayerRun
jumpSpr = sPlayerJump

//moving
face = 1
moveDir = 0
runType = 0
moveSpd[0] = 2
moveSpd[1] = 3.5

moveSpdMax[0] = 2
moveSpdMax[1] = 3.4
moveAcc[0] = .1
moveAcc[1] = .2
moveFric[0] = .2
moveFric[1] = .1

xspd = 0
yspd = 0

//jumping
grav = .275
termVel = 4
onGround = true

//jump values for each successive jump 
		//( each jump can have an array of different values set bu "jumpCount"
jspd = -4
jumpMax = 1
jumpCount = 0
jumpHoldTimer = 0
jumpHoldFrames = 12

//coyote time
//hang time
coyoteHangFrames = 3
coyoteHangTimer = 0
//jump buffer time
coyoteJumpFrames = coyoteHangFrames * 2
coyoteJumpTimer = 0

//moving platfroms
myFloorPlat = noone
earlyMovePlatXspd = false
downSlopeSemiSolid = noone
forgetSemiSolid = noone
movePlatXspd = 0
movePlatMaxYspd = termVel //how fast can player fall down moving platform