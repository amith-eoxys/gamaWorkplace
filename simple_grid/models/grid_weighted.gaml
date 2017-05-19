/**
* Name: gridweighted
* Author: Eoxys-Win10
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model gridweighted

global {
	file dem <- file("../includes/vulcano_50.asc");
	geometry shape <- envelope(dem);
	string algorithm <- "A*" among: ["A*", "Dijkstra", "JPS", "BF"] parameter: true;
	
	int neighborhood_type <- 8 among:[4,8] parameter: true;
	path my_path <- nil;
	map<cell,float> cell_weights;
	int save_at <- 10000;
	list target_point <- [{7.5,40.5,0},{35.5,45.5,0},{5.5,6.5,0},{45.5,8.5,0}];//,{100,600,0},{850,550,0}]; 
	int i <- 0;
	int row_nbr <- 50;
	int clm_nbr <- 50;
	int a <- 0;
	int b <- 0;
	int c <- 0;
	int d <- 0;
	
	init {    
			create goal number: length(target_point){
					
			point loc <- (target_point at i);
			location <- (loc);//.location;
			//write i;
			//write location;
			i<-i+1;
		}
		
		
		//ask cell {grid_value <- grid_value * 5;}  
		float max_val <- cell max_of (each.grid_value);
		ask cell {
			float val <- 255 * (1 - grid_value / max_val);
			color <- rgb(val, val,val);
		}
		cell_weights <- cell as_map (each::each.grid_value);
		create people number: 1 {
			target <- (goal) at 1;//rnd(length(target_point)-1);
			location <-  (one_of (cell).location);
		}
	}
	
	reflex save_grid when: cycle = save_at{
		ask people{
		save trajectories to:"../results/trajectory10.csv" type:"csv";
		
		}
		save [a,b,c,d] to:"../results/freq.csv" type:"csv";
		save cell to:"../results/grid10.asc" type:"asc";
		do pause;
	} 
}

grid cell file: dem neighbors: neighborhood_type optimizer: algorithm {
	//grid_value <- 0;
} 
	 
species goal {
	
	aspect default { 
		draw circle(0.5) color: #red;
	}
}  
	
	  
species people skills: [moving] {
	bool target_flag <- false;
	goal target ;//<- one_of (goal);
	float speed <- float(1);
	path my_path ;
	list<geometry> trajectories;
	
	aspect default {
		draw circle(0.5) color: #green;
		if (current_path != nil) {
			draw current_path.shape color: #red;
		}
	}
	
	reflex change_goal when: target_flag{
		if (target.location distance_to (goal at 0)) <= 2 {
			a <- a + 1;
			
		int var0 <- rnd_choice([0.25,0.25,0.25,0.25]);
		target <-  (goal) at var0;
		target_flag <- false;
		
		}
		
		else if (target.location distance_to (goal at 1)) <= 2{
			b <- b+1;
		int var0 <- rnd_choice([0.25,0.25,0.25,0.25]);
		target <-  (goal) at var0;
		target_flag <- false;
		
		}
		else if (target.location distance_to (goal at 2)) <= 2{
			c <- c+1;
		int var0 <- rnd_choice([0.25,0.25,0.25,0.25]);
		target <-  (goal) at var0;
		target_flag <- false;
		
		}
		else { //if target.location = goal at 3{
		d<-d+1;
		int var0 <- rnd_choice([0.25,0.25,0.25,0.25]);
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
	reflex move {
		
		
		path followed_path <- self  goto (on:cell_weights, target:target, speed:speed,return_path: true, recompute_path: false);//on:(cell),
		//write followed_path;
		list<geometry> segments <- followed_path.segments;

		loop line over: segments
		{
			trajectories << line;
		}	
				
		if int(self distance_to target) <= 1 {
			target_flag <- true;
			//my_path <- nil;
			}	
	}
}

experiment weighted_grid type: gui {
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
				data "D" value: d;
			}
		}
	}
}