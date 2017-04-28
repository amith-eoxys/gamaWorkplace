/**
* Name: test_code
* Author: Amith
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model test_code

global {
	//Shapefile of the walls
	file wall_shapefile <- file("../includes/house.dxf");
	
	//DImension of the grid agent
	int nb_cols <- 50;
	int nb_rows <- 50;
	
	list target_point <- [{100,200,0},{700,150,0}];
	//Shape of the world initialized as the bounding box around the walls
	geometry shape <- envelope(wall_shapefile);
	
	init {
		//Creation of the wall and initialization of the cell is_wall attribute
		create wall from: wall_shapefile {
			ask cell overlapping self {
				is_wall <- true;
			}
		}
		
		//Creation of tsrgets
		create targets from: target_point {
			ask (cell overlapping self) where not each.is_wall{
				target <- true;
			}
		} 
			//Creation of the people agent
		create people number: 5{
			//People agent are placed randomly among cells which aren't wall
			location <- one_of(cell where not each.is_wall).location;
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
//Species which represent the wall
species wall {
	aspect default {
		draw shape color: #black depth: 30;
	}
}
//Species which represent the people moving from their location to an exit using the skill moving
species people skills: [moving]{
	//Evacuation point
	bool is_target;
	bool is_exit;
	point target <- target_point at 0;
	rgb color <- rnd_color(255);
	
	reflex goto_other_target when: target = nil {
		
		target <- target_point at 1	;
		
}
	//Reflex to move the agent 
	reflex move {
		//Make the agent move only on cell without walls
		
		
		do goto target: target speed: 2 on: (cell where not each.is_wall);// recompute_path: false;
		/*switch target{
			match location {
				target <- nil;
				write target;
			}
		}*/
		//If the agent is close enough to the target, change target
		if (self distance_to target) < 2.0 {
			target <- nil;
			//list<people> ch_people <- self;
			write target;
		}
	}
	aspect default {
		draw pyramid(10) color: color;
		draw sphere(5) at: {location.x,location.y,4} color: color;
	}
}
experiment test_code type: gui {
	output {
		display map type: opengl{
			
			species wall refresh: false;
			species targets refresh: false;
			species people;
			
			graphics "exit" refresh: false {
				//loop i over: target_point{
				draw sphere(2 * 10) at: first(target_point) color: #green;
				draw sphere(2* 10) at: ((target_point) at 1) color: #red;
					
				}
			}
		}
}


