/**
* Name: go2grid
* Author: Eoxys-Win10
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model go2grid

global {
	int save_at <- 1000;
	list target_point <- [{3.5,4.5,0},{10.5,20.5,0},{40.5,30.5,0}];//,{100,600,0},{850,550,0}]; 
	int i <- 0;
	int row_nbr <- 50;
	int clm_nbr <- 50;
	int a <- 0;
	int b <- 0;
	int c <- 0;
	
	init {    
			create goal number: length(target_point){
					
			point loc <- (target_point at i)*2;
			location <- (loc).location;
			//write i;
			//write loc;
			i<-i+1;
		}
		create people number: 1 {
			target <- (goal) at rnd(length(target_point)-1);
			location <-  (one_of (cell).location);
		}
	}
	
	reflex save_grid when: cycle = save_at{
		ask people{
		save trajectories to:"../results/trajectory.csv" type:"csv";
		
		}
		save [a,b,c] to:"../results/freq.csv" type:"csv";
		save cell to:"../results/grid.asc" type:"asc";
		do pause;
	} 
}

grid cell width: row_nbr height: clm_nbr neighbors: 4 {
	//grid_value <- 0;
} 
	 
species goal {
	
	aspect default { 
		draw circle(1) color: #red;
	}
}  
	
	  
species people skills: [moving] {
	bool target_flag <- false;
	goal target ;//<- one_of (goal);
	float speed <- float(2);
	list<geometry> trajectories;
	
	aspect default {
		draw circle(1) color: #green;
	}
	
	reflex change_goal when: target_flag{
		if (target.location distance_to (goal at 0)) <= 2 {
			a <- a + 1;
			
		int var0 <- rnd_choice([0,0.3,0.7]);
		target <-  (goal) at var0;
		target_flag <- false;
		
		}
		
		else if (target.location distance_to (goal at 1)) <= 2{
			b <- b+1;
		int var0 <- rnd_choice([0.3,0,0.7]);
		target <-  (goal) at var0;
		target_flag <- false;
		
		}
		else { //if target.location = goal at 3{
		c<-c+1;
		int var0 <- rnd_choice([0.5,0.5,0]);
		target <-  (goal) at var0;
		target_flag <- false;
		
		}
		//write [a,b,c];
		
	}
	
	reflex update_gridvalues{
		//ask cell{
			//(grid_value at self.location) <- (grid_value at self.location) + 1;
			cell(location).grid_value <- cell(location).grid_value + 1;
			//write cell(location).grid_value;
		//}
	}
	reflex move {//when: location != target{
		
		//Neighs contains all the neighbours cells that are reachable by the agent plus the cell where it's located
		list<cell> neighs <- (cell(location) neighbors_at speed) + cell(location); 
		
		//We restrain the movements of the agents only at the grid of cells that are not obstacle using the on facet of the goto operator and we return the path
		//followed by the agent
		//the recompute_path is used to precise that we do not need to recompute the shortest path at each movement (gain of computation time): the obtsacles on the grid never change.
		path followed_path <- self goto (on:cell, target:target, speed:speed, return_path:true, recompute_path: true);
		
		list<geometry> segments <- followed_path.segments;
		write segments;
		
		loop line over: segments
		{
			trajectories << line;
		}	
			
		if int(self distance_to target) <= 2 {
			target_flag <- true;
			
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
		display Simple_chart {
			chart "Simple Chart" type:histogram{
				data "A" value: a;
				data "B" value: b;
				data "C" value: c;
			}
		}
	}
}
