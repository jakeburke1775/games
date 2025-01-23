getControls()

{//moving platforms
	{//get out of any solid moving platorms

		var _rightWall = noone
		var _leftWall = noone
		var _bottomWall = noone
		var _topWall = noone
		var _list = ds_list_create()
		var _listSize = instance_place_list( x, y, oMovePlat, _list, false)

		//loop through colliding moving platforms
		for ( var i = 0; i < _listSize; i++ )
		{
			var _listInst = _list[| i]
		
			//find th closest wall in each direction
				//RIGHT WALL ( if there are walls to the right of the player, get to the closest one
				if _listInst.bbox_left - _listInst.xspd >= bbox_right - 1 // -1 for extra buffer
				{
					if !_rightWall || _listInst.bbox_left < _rightWall.bbox_left
					{
						_rightWall = _listInst
					}
				}
				//LEFT WALL
				if _listInst.bbox_right - _listInst.xspd <= bbox_left + 1
				{
					if !_leftWall || _listInst.bbox_right > _leftWall.bbox_right
					{
						_leftWall = _listInst
					}
				} 
				//BOTTOM WALL
				if _listInst.bbox_top - _listInst.yspd >= bbox_bottom - 1
				{
					if !_bottomWall || _listInst.bbox_top < _bottomWall.bbox_top
					{
						_bottomWall = _listInst
					}
				}
				//TOP WALL
				if _listInst.bbox_bottom - _listInst.yspd <= bbox_top + 1
				{
					if !_topWall || _listInst.bbox_bottom > _topWall.bbox_bottom
					{
						_topWall = _listInst
					}
				}
		}

		//destroy the list to free memory
		ds_list_destroy( _list )
	
		//get out of the walls
			//right Walls
			if instance_exists( _rightWall )
			{
				var _rightDist = bbox_right - x
				x = _rightWall.bbox_left - _rightDist
			}
			//left Walls
			if instance_exists( _leftWall )
			{
				var _leftDist = x - bbox_left
				x = _leftWall.bbox_right + _leftDist
			}
			//bottom Walls
			if instance_exists( _bottomWall )
			{
				var _bottomDist = bbox_bottom - y
				y = _bottomWall.bbox_top - _bottomDist
			}
			//top Walls ( includes collision for polish and crouching features
			if instance_exists( _topWall )
			{
				var _upDist = y - bbox_top
				var _targetY = _topWall.bbox_bottom + _upDist
				//check if there isnt a wall in the way
				if !place_meeting( x, _targetY, oWall )
				{
					y = _targetY
				}
			}
	}	

	{//dont get left behind by moveplat
	earlyMovePlatXspd = false
	if instance_exists( myFloorPlat ) && myFloorPlat.xspd != 0 && place_meeting( x, y + movePlatMaxYspd + 1, myFloorPlat )
	{
		//move player back onto that platform if there is no wall in the way
		if !place_meeting( x + myFloorPlat.xspd, y, oWall )
		{
			x += myFloorPlat.xspd
			earlyMovePlatXspd = true
		}
	}}
}

{	//x movement (smooth acceleration) ***FUTURE PROJECT
		//direction
		moveDir = rightKey - leftKey

		//get xspd
		runType = runKey
		xspd += moveDir * moveAcc[runType]

		xspd = clamp( xspd, -moveSpdMax[runType], moveSpdMax[runType] )

		if moveDir = 0 and xspd > 0
			xspd -= moveFric[0]
		if moveDir = 0 and xspd < 0
			xspd += moveFric[0]
			
		if moveDir = 0 and abs(xspd)<.3				//get rid of residual acceleration
			xspd = 0		
			
			//my face
		if moveDir != 0 {face = moveDir	}
}

{/*//x movement, direction, facing , xspd
	//direction
	moveDir = rightKey - leftKey
	
	//my face
	if moveDir != 0 {face = moveDir	}

	//get xspd
	runType = runKey
	xspd = moveDir * moveSpd[runType]*/}
	
{//x collision
	var _subPixel = .5

	//run into walls
	if place_meeting( x + xspd, y, oWall )
	{
		//first check if there is a slope to go up
		if !place_meeting( x + xspd, y - abs( xspd ) - 1, oWall )
		{	while place_meeting( x + xspd, y, oWall )	{ y -= _subPixel }}
	
		else //next, check for ceiling slopes, otherwise regular collision 
	
		{	//ceiling slopes
			if !place_meeting( x + xspd, y + abs( xspd ) + 1, oWall )
			{	while place_meeting( x + xspd, y, oWall ) { y += _subPixel}}
			//normal collision 
			else {	//scoot up to wall precisely
				var _pixelCheck = _subPixel * sign(xspd)
				while !place_meeting( x + _pixelCheck, y, oWall )	{ x +=_pixelCheck }
				//set xspd to 0 to collide
				xspd = 0
			}
		}
	}

	//go down slopes
	downSlopeSemiSolid = noone
	if yspd >= 0 && !place_meeting( x + xspd, y + 1, oWall) 
	&& place_meeting( x + xspd, y + abs( xspd )+1, oWall)
		{
			//check for a semisolid in the way
			downSlopeSemiSolid = checkForSemiSolidPlat( x + xspd, y + abs( xspd ) + 1 )
			//precisely move down slope if there isnt a semisolid in the way
			if !instance_exists( downSlopeSemiSolid )
			{
				while !place_meeting( x + xspd, y + _subPixel, oWall ) { y += _subPixel }
			}
		}

	//move
	x += xspd
}
                                                                                                                                                                          
{//Y movement
	//gravity
	if coyoteHangTimer > 0 {	coyoteHangTimer--	}
	else {	yspd+= grav	setOnGround(0)}

	//reset/prepare  jumping variables
	if onGround
		{	jumpCount = 0 coyoteJumpTimer = coyoteJumpFrames	}
	else  
	{	coyoteJumpTimer-- 
		if jumpCount = 0 && coyoteJumpTimer <= 0 
			{	jumpCount = 1	}}

	//initiate the jump
	var _floorIsSolid = false
	if instance_exists( myFloorPlat )
	&& ( myFloorPlat.object_index == oWall || object_is_ancestor( myFloorPlat.object_index, oWall ) )
	{
		_floorIsSolid = true
	}
	if jumpKeyBuffered && !downKey && jumpCount < jumpMax
	{	//reset the buffer
		jumpKeyBuffered = false
		jumpKeyBufferTimer = 0
		//increase number of performed jumps
		jumpCount++
		// set the jumpHoldTimer
		jumpHoldTimer = jumpHoldFrames	
		//we are no longer on the ground
		setOnGround(0)	
	}
	
	//jump based on the timer/holding the button				[1]	this code must be before jumphold timer release (below)
	if jumpHoldTimer > 0 
	{	//constantly set the yspd to be jumping speed
		yspd = jspd
		//count down the timer
		jumpHoldTimer--	}
		
	//cut off the jumphold timer by releasing the jump button	[2]	this code must be after jumphold code above^
	if !jumpKey
		jumpHoldTimer = 0
	
	//Y collision and movement 		
		//cap falling speed
		if yspd > termVel { yspd = termVel }
	
		//Y collide
		var _subPixel = 1
		
		//upwards Y collision (with ceiling)
		if yspd < 0 && place_meeting( x, y + yspd, oWall )
		{
			//jump into slopped ceilings
			var _slopeSlide = false
				//slide upleft
				if moveDir == 0 && !place_meeting( x - abs( yspd ) - 1, y + yspd, oWall)
					{	while place_meeting( x, y + yspd, oWall )	{	x -= 1	}
						_slopeSlide = true	}
				//slide upright
				if moveDir == 0 && !place_meeting( x + abs( yspd ) + 1, y + yspd, oWall)
					{	while place_meeting( x, y + yspd, oWall )	{	x += 1	}
						_slopeSlide = true	}
				//normal Y collisiion
				if !_slopeSlide
				{
					//scoot precisely
					var _pixelCheck = _subPixel * sign( yspd )
					while !place_meeting( x,  y +_pixelCheck, oWall )	{	y += _pixelCheck	}
			
					//bonk code (optional, for colliding with a platform above
					if yspd < 0	
						jumpHoldTimer = 0
						
					//set yspd to 0 to collide
					yspd = 0	
			
				}
		}

		{//Floor Y colision
		
		//check for solid and semisolid plats under me
		var _clampYspd = max( 0, yspd )
		var _list = ds_list_create()	//create a ds list of all the objects we run into
		var _array = array_create(0)
		array_push( _array, oWall, oSemiSolidWall )
		
		//do the actual check and add objects to list
		var _listSize = instance_place_list( x, y + 1 + _clampYspd + movePlatMaxYspd, _array, _list, false)
		
			//FIX FOR HIG RES/HIGH SPEED PROJECTS
			var _yCheck = y + 1 + _clampYspd
			if instance_exists( myFloorPlat )	{ _yCheck += max( 0, myFloorPlat.yspd ) }
			var _semiSolid = checkForSemiSolidPlat( x, _yCheck)
 		
		//loop through the coliding instances and only returnn 1 if its top is below the player
		for( var i = 0; i < _listSize; i++ )
			{
				//get an instance of oWall or oSemiSolidWall from the list
				var _listInst = _list[| i]
				
				//avoid magnetism
				if (
				_listInst != forgetSemiSolid
				&& ( _listInst.yspd <= yspd || instance_exists( myFloorPlat ) )
				&& ( _listInst.yspd > 0 || place_meeting( x, y + 1 +_clampYspd, _listInst ) ) 
					)
				|| ( _listInst == _semiSolid ) // HIGH SPEED FIX
				{//return a solid wall or any semisolidwalls that are below the player
					if _listInst.object_index == oWall
					|| object_is_ancestor( _listInst.object_index, oWall )
					|| floor( bbox_bottom ) <= ceil( _listInst.bbox_top - _listInst.yspd )
					{
						//return the "highest" wall object
						if !instance_exists( myFloorPlat )
						|| _listInst.bbox_top + _listInst.yspd <= myFloorPlat.bbox_top +myFloorPlat.yspd
						|| _listInst.bbox_top + _listInst.yspd <= bbox_bottom
						{
							myFloorPlat = _listInst
						}
					}
				}
			}
			//destroy the ds list to avoid memory leak
			ds_list_destroy( _list )
			
			//downslope semisolid for making sure we dont miss semisolid's while going down slopes
			if instance_exists( downSlopeSemiSolid ) { myFloorPlat = downSlopeSemiSolid }
		
			//one last check to make sure platform is actually below us
			if instance_exists( myFloorPlat ) && !place_meeting( x, y + movePlatMaxYspd, myFloorPlat )
			{	myFloorPlat = noone	}
			
			//land on the ground platform if there is one
			if instance_exists( myFloorPlat )
				{
					//scoot up wall precicely 
					var _subPixel = .5
					while !place_meeting( x, y + _subPixel, myFloorPlat ) && !place_meeting( x, y, oWall ) { y += _subPixel }
					//make sure we dont end up below the top of a semiSolid
					if myFloorPlat.object_index == oSemiSolidWall || object_is_ancestor( myFloorPlat.object_index, oSemiSolidWall )
					{
						while place_meeting( x, y, myFloorPlat ) { y -= _subPixel}
					}
					//floor the y variable
					y = floor( y )
					
					//colide with the ground
					yspd = 0
					setOnGround()
				}		
		}
		
		//manually fall through a semisolid platform
		if downKey && jumpKeyPressed
		{
			//make sure there is a floor platform thats semisolid
			if instance_exists( myFloorPlat )
			&& ( myFloorPlat.object_index == oSemiSolidWall || object_is_ancestor( myFloorPlat.object_index, oSemiSolidWall ) )
			{
				//check if we can go below the semisolid
				var _yCheck = max( 1, myFloorPlat.yspd + 1 )
				if !place_meeting( x, y + _yCheck, oWall )
				{
					//move below the platform
					y += 1
					
					//inherit anydownward speed from my floor platform so it doesnt catch the player
					yspd = _yCheck + 1
					
					//forget for a breif tiime the platfrom 
					forgetSemiSolid = myFloorPlat
					
					setOnGround( false )
				}
			}
		}
		
		//move
		if !place_meeting( x, y + yspd, oWall ) { y += yspd }
		
		// reset forgetSemiSolid variable
		if instance_exists( forgetSemiSolid ) && place_meeting( x, y, forgetSemiSolid )
		{
			forgetSemiSolid = noone
		}
}
		
{//final moving platform collision and movement
	
	//x moveplat xspd
	// get the movePlat xspd
	movePlatXspd = 0;
	if instance_exists( myFloorPlat ) { movePlatXspd = myFloorPlat.xspd; }
	
	//move with movePLatXspd
	if !earlyMovePlatXspd
	{	if place_meeting( x + movePlatXspd, y, oWall )
		{
			//scoot up to wall precicely
			var _subPixel = .5;
			var _pixelCheck = _subPixel + sign( movePlatXspd );
			while !place_meeting( x + _pixelCheck, y, oWall ) { x += _pixelCheck; }
			movePlatXspd = 0;
		}
	
	
		//move 
		x += movePlatXspd;
	}

	//y-snap player to myFloorPlat
	if instance_exists( myFloorPlat ) 
	&& ( myFloorPlat.yspd != 0 
	|| myFloorPlat.object_index == oMovePlat
	|| object_is_ancestor( myFloorPlat.object_index, oMovePlat )
	|| myFloorPlat.object_index == oSemiSolidMovePlat
	|| object_is_ancestor( myFloorPlat.object_index, oSemiSolidMovePlat )	)
	{	//snap to the top of the floor platform (un-floor the y variable so its not choppy
		if !place_meeting( x, myFloorPlat.bbox_top, oWall)
		&& myFloorPlat.bbox_top >= bbox_bottom - movePlatMaxYspd
		{
			y = myFloorPlat.bbox_top;
		}
		
		//code made redundant by code below***
						//going up into a solid wall while on a semisoldi platform
						/*if myFloorPlat.yspd < 0 && place_meeting( x, y + myFloorPlat.yspd, oWall )
						{
							//get pushed down through the semisolid floor platform
							if myFloorPlat.object_index == oSemiSolidWall || object_is_ancestor( myFloorPlat.object_index, oSemiSolidWall )
							{
								//get pushed down through the semisolid
								var _subPixel = .25
								while place_meeting( x, y + myFloorPlat.yspd, oWall ) { y += _subPixel }
								//if get pushed into a solid wall going downwards, push back out
								while place_meeting( x, y, oWall ) { y -= _subPixel }
								y = round( y )
				
							}
							//cancel myFloorPlat variable
							setOnGround(false)
						}*/
	}
	
	//get pushed down through a semisolid by a moving solid platform
	if instance_exists( myFloorPlat )
	&& (myFloorPlat.object_index == oSemiSolidWall || object_is_ancestor( myFloorPlat.object_index, oSemiSolidWall ) )
	&& place_meeting( x, y, oWall )
	{
		//if player is already stuck in a wall, try and move down to get below a semisolid
		//if still stuck afterward, that just means player has been properly "crushed"
		//also, dont check too far, player shall not warp through walls
		
		var _maxPushDist = 10
		var _pushedDist = 0
		var _startY = y
		while place_meeting( x, y, oWall) && _pushedDist <= _maxPushDist
		{
			y++
			_pushedDist++
		}
		//forget myFloorPlat
		myFloorPlat = false
		
		//if player still in a wall they have been crushed
		if _pushedDist > _maxPushDist { y = _startY }
		
	}
}
		

//check if im crushed
image_blend = c_lime
if place_meeting( x, y, oWall)
{
	image_blend = c_lime;
}
	//crushed death code added here, add timer with 3 frames to eliminate small bugs
	

{//sprite control
	
	//walking
		if abs( xspd ) > 0 { image_speed = .7; }
	//running
		if abs( xspd ) > 0 { image_speed = 1; }
	//not moving
		if xspd == 0 { image_speed = 0; }
	//in the air
		if !onGround { image_speed = 0; }
	//set collision mask
	mask_index = idleSpr;
}