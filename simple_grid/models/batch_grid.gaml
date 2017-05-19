/**
* Name: batchgrid
* Author: Eoxys-Win10
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model batchgrid

global {
	int save_at <- 10000;
	list target_point <- [{7.5,40.5,0},{35.5,45.5,0},{5.5,6.5,0},{45.5,8.5,0}];//,{100,600,0},{850,550,0}]; 
	int i <- 0;
	int row_nbr <- 50;
	int clm_nbr <- 50;
	int a <- 0;
	int b <- 0;
	int c <- 0;
	int d <- 0;
	list<geometry> trajectories;
	//int cnt ;
	reflex save when: cycle = save_at{
		write name;
		save trajectories to:"../results/trajectory" + name + ".csv" type:"csv";
		save [a,b,c,d] to:"../results/freq.csv" type:"csv";
		save cell to:"../results/grid"+ name + ".asc" type:"asc";
	}
	
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
			location <- (one_of (cell).location); // cell[25, 25];
		}
	}
}

grid cell width: row_nbr height: clm_nbr neighbors: 8 {
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
	
	
	aspect default {
		draw circle(1) color: #green;
	}
	
	reflex change_goal when: target_flag{
		if (target.location distance_to (goal at 0)) <= 2 {
			a <- a + 1;
			
		int var0 <- rnd_choice([0.05,0.3,0.2,0.45]);
		target <-  (goal) at var0;
		target_flag <- false;
		
		}
		
		else if (target.location distance_to (goal at 1)) <= 2{
			b <- b+1;
		int var0 <- rnd_choice([0.4,0.05,0.3,0.25]);
		target <-  (goal) at var0;
		target_flag <- false;
		
		}
		else if (target.location distance_to (goal at 2)) <= 2{
			c <- c+1;
		int var0 <- rnd_choice([0.2,0.1,0,0.7]);
		target <-  (goal) at var0;
		target_flag <- false;
		
		}
		else { //if target.location = goal at 3{
		d<-d+1;
		int var0 <- rnd_choice([0.3,0.3,0.3,0.1]);
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
		
		
		path followed_path <- self goto (on:cell, target:target, speed:speed, return_path: true, recompute_path: false);
		
		list<geometry> segments <- followed_path.segments;
		write followed_path;
		
		loop line over: segments
		{
			trajectories << line;
		}	
			
		if int(self distance_to target) <= 2 {
			target_flag <- true;
			
			}	
	}
}

experiment batch_goto_grid type: batch repeat: 10 keep_seed: false until: (cycle = (save_at + 1)) {

	
	output {
	//	permanent{
		display objects_display refresh:every(2){
			grid cell lines: #black;
			species goal aspect: default ;
			species people aspect: default ;
		}
		}
		/*
		permanent{
		display Simple_chart {
			chart "Simple Chart" type:histogram{
				data "A" value: a;
				data "B" value: b;
				data "C" value: c;
				data "D" value: d;
			}
		}
*/		
	
}

