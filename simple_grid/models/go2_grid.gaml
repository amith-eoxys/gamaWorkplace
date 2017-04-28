/**
* Name: go2grid
* Author: Eoxys-Win10
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model go2grid

global {
	list target_point <- [{3,4,0},{1,2,0},{7,3,0}];//,{100,600,0},{850,550,0}]; 
	
	init {    
		//loop times: length(target_point) {
		//	point loc <- target_point;
		//	list<cell> target <- (cell grid_at loc);
			/*ask food_places {
				if food = 0 {
					food <- 5;
					food_placed <- food_placed + 5;
					color <- food_color;  
				}                                           
			}*/
		//}
		//cell target <- cell closest_to target_point; 
		
		create goal number: length(target_point){
			loop i from:0 to: length(target_point)-1 {
				ask target_point at i{
			point loc <- self;
			location <- (cell grid_at loc).location;
			//write i;
			//write loc;
			}
			}
			
		}
		create people number: 1 {
			target <- (goal) at 2;
			location <-  (one_of (cell where not each.is_obstacle)).location;
		}
	} 
}

grid cell width: 50 height: 50 neighbors: 4 {
	bool is_obstacle <- flip(0.02);
	rgb color <- is_obstacle ? #black : #white;
} 
	 
species goal {
	/*init {
		loop i from: 0 to: length(target_point)-1 {
			point loc <- (target_point) at i;
			location <- (cell grid_at loc).location;
			
			}
	}*/
	aspect default { 
		draw circle(0.5) color: #red;
	}
}  
	
	  
species people skills: [moving] {
	bool target_flag <- false;
	goal target ;//<- one_of (goal);
	float speed <- float(3);
	
	aspect default {
		draw circle(0.5) color: #green;
	}
	
	reflex change_goal when: target_flag{
		target <-  (goal) at rnd(2);
		target_flag <- false;
	}
	
	reflex move {//when: location != target{
	write target.location;
	write location;
	write self distance_to target;
	if int(self distance_to target) < 3 {
			target_flag <- true;
			
			}
			write target_flag;
		//Neighs contains all the neighbours cells that are reachable by the agent plus the cell where it's located
		list<cell> neighs <- (cell(location) neighbors_at speed) + cell(location); 
		
		//We restrain the movements of the agents only at the grid of cells that are not obstacle using the on facet of the goto operator and we return the path
		//followed by the agent
		//the recompute_path is used to precise that we do not need to recompute the shortest path at each movement (gain of computation time): the obtsacles on the grid never change.
		path followed_path <- self goto (on:(cell where not each.is_obstacle), target:target, speed:speed, return_path:true, recompute_path: false);
		
		//As a side note, it is also possible to use the path_between operator and follow action with a grid
		//Add a my_path attribute of type path to the people species
		//if my_path = nil {my_path <- path_between((cell where not each.is_obstacle), location, target);}
		//path followed_path <- self follow (path: my_path,  return_path:true);
		
		if (followed_path != nil) and not empty(followed_path.segments) {
			geometry path_geom <- geometry(followed_path.segments);
			
			//The cells intersecting the path followed by the agent are colored in magenta
			ask (neighs where (each.shape intersects path_geom)) { color <- #magenta;}
		}	
	}
}

experiment goto_grid type: gui {
	output {
		display objects_display {
			grid cell lines: #black;
			species goal aspect: default ;
			species people aspect: default ;
		}
	}
}
