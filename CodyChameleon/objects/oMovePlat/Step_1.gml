//movein a circle 
dir += rotSpd

//get our target positions
var _targetX = xstart + lengthdir_x( radius, dir )
var _targetY = ystart + lengthdir_y( radius, dir )

//get our xspd and yspd
xspd = _targetX - x
yspd = 0//(_targetY - y) /2800

x += xspd
y += yspd