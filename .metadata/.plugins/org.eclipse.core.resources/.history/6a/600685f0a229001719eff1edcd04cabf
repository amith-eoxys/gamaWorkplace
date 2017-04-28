model Network
// Proposed by Patrick Taillandier

global {
	file shape_file_in <- file('../includes/gis/Reseau_TC.shp') ;
	graph the_graph; 
	geometry shape <- envelope(shape_file_in);
	bool flood <- false;
	init {    
		create road from: shape_file_in ;
		the_graph <- as_edge_graph(list(road));
		 
		create goal number: 1 {
			location <- any_location_in (one_of(road));
		}
		create people number: 100 {
			target <- one_of (goal) ;
			location <- any_location_in (one_of(road));
		} 
		ask landuse {
			if (grid_x< 20 and grid_y< 20) {
				type <- "swamp";
				color <- rgb("orange");
			} else {
				type <- "normal";
				
				color <- rgb("white");
			}
			my_roads <- road overlapping self;
		}
	}
	
	reflex flooding when: not flood and flip(0.01){
		write "ovo";
		ask (landuse where (each.type = "swamp")) {
			loop rd over: my_roads {
				rd.closed <- true;
			}
		}
		flood <- true;
		map<road,float> weights_map <- road as_map (each:: ((each.closed ? 99999999.9 : 1.0) * each.shape.perimeter));
		the_graph <- as_edge_graph(road) with_weights weights_map;
		
	}
	
	reflex endflooding when: flood and flip(0.005){
		ask (road where each.closed) {
			closed <- false;
		}
		flood <- false;
		map<road,float> weights_map <- road as_map (each:: ((each.closed ? 99999999.9 : 1.0) * each.shape.perimeter));
		the_graph <- as_edge_graph(road) with_weights weights_map;
	}
	
}
species road  {
	bool closed <- false;
	aspect default {
		draw shape color: closed ? rgb("red") : rgb('black') ;
	}
} 
	
species goal {
	aspect default {
		draw circle(100) color: rgb('red');
	}
}
	
species people skills: [moving] {
	goal target;
	path my_path; 
	
	aspect default {
		draw circle(100) color: rgb('green');
	}
	reflex movement {
		do goto on:the_graph target:target speed:10.0;
	}
}

grid landuse width: 50 height: 50 {
	list<road> my_roads;
	string type;
	rgb color update: type = "normal" ? rgb("white") : rgb("orange");
	
	reflex change_landuse when: type = "normal" {
		list<landuse> neigh <- self neighbours_at 1;
		int nb_tot <- length(neigh);
		int nb <- neigh count (each.type = "swamp");
		if (flip (0.01 *nb/ nb_tot)) {
			type <- "swamp";
		}
	}
	
}


experiment goto_network type: gui {
	output {
		display objects_display {
			grid landuse lines: rgb("black");
			species road aspect: default ;
			species people aspect: default ;
			species goal aspect: default ;
			
		}
	}
}
