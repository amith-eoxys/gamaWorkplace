/**
* Name: gridmove
* Author: Eoxys-Win10
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model gridmove

global {
	
	//DImension of the grid agent
	int nb_cols <- 50;
	int nb_rows <- 50;
	
	list target_point <- [{10,40,0},{37,40,0},{47,16,0}];//,{100,600,0},{850,550,0}];
	
	init {
			
		//Creation of targets
		create targets from: target_point {
			ask (cell overlapping self) {
				target <- true;
			}
		} 
			//Creation of the people agent
		create people number: 1{
			//People agent are placed randomly among cells which aren't wall
			location <- one_of(cell).location;
			//Target of the people agent is one of the possible exits
			
			}
		
	}
}
//Grid species to discretize space
grid cell width: nb_cols height: nb_rows neighbors: 8 {
	bool is_wall <- false;
	bool target <- false;
	//rgb color <- #red;	
}
//Species exit which represent the exit
species targets {
	aspect default {
		draw sphere(10) color: #blue;
	}
}
//Species which represent the people moving from their location to an exit using the skill moving
species people skills: [moving]{
	//Evacuation point
	bool target_flag;
	//bool is_target;
	//bool is_exit;
	point target <- target_point at rnd(length(target_point)-1);
	rgb color <- rnd_color(255);
	
	reflex goto_other_target when: target_flag = true {
		target <- target_point at rnd(length(target_point)-1);
	}
		
	//Reflex to move the agent 
	reflex move {
		//Make the agent move only on cell without walls
		
		
		do goto target: target speed: 1 on: (cell);// recompute_path: false;
		
		//If the agent is close enough to the target, change target
		if (self distance_to target) < 10 {
			target_flag <- true;
			
			//list<people> ch_people <- self;
			write target;
		}
	}
	aspect default {
		draw pyramid(2) color: color;
		//draw sphere(5) at: {location.x,location.y,4} color: color;
	}
}
experiment test_code type: gui {
	output {
		display map type: opengl{
			
			//species wall refresh: false;
			species targets refresh: false;
			species people;
			
			graphics "exit" refresh: false {
				//loop i over: target_point{
				//draw sphere(2) at: first(target_point) color: #green;
				//draw sphere(2) at: ((target_point) at 1) color: #red;
				//draw sphere(2) at: ((target_point) at 2) color: #blue;
				//draw sphere(2* 10) at: ((target_point) at 3) color: #dimgray;
				//draw sphere(2* 10) at: ((target_point) at 4) color: #yellow;
				}
			}
			display MyDisplay type: java2D {
            grid cell lines:#black;
            //species my_species aspect:default; 
        }
		}
}

