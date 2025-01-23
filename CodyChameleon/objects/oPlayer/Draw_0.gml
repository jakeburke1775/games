//draw myself
str[0] = "be professional in the test room please"
str[1] = "press R to reset the test room"
str[2] = "arrow keys or wasd to move"
str[3] = "space to jump, hold down for greater height"
str[4] = "shift to run"
str[5] = "down button + jump = climb down"


for (i = 0; i< array_length(str); i++) {
	draw_text_ext_transformed(16,16+(i*16),str[i],16,400,.5,.5,2);
	}
draw_text_ext_transformed(300,100,"you can jump through blue `semi-solid` platforms",16,400,.5,.5,-2);
draw_sprite_ext( sprite_index, image_index, x, y, image_xscale * face, 1, 0, c_white, 1)