/**
 *  dim_traffic_example
 *  Author: Dimitris
 *  Description: evolution of a traffic model
 */
model dim_traffic_example


global
{
	file shape_file_buildings <- file("../includes/building.shp");
	file shape_file_roads <- file("../includes/road.shp");
	//    file shape_file_bounds <- file('../includes/bounds.shp');
	//  instead of indicating bounds we give the geometry shape > we use a shapefile to automatically define it by computing its envelope
	geometry shape <- envelope(shape_file_roads);
	//  
	// A "reflex" is a sequence of statements that can be executed, at each time step, by the agent
	// A "Init" is evaluated only once when the agent is created, after the initialization of its variables
	// and before it exectutes any "reflex"    
	int nb_adults <- 100;
	int nb_children <- 60;
	int nb_elderly <- 60;
	int cycle_to_save <- 50;
	// The value of the day_time variable is automatically computed at each simulation step and is equals to 
	// "time (the simulation step) modulo 24" (one day is decomposed in 24 simulation steps)Therefore every step is 1 hour.         
	int day_time update: time mod 24;
	int min_work_start_a <- 6;
	int max_work_start_a <- 10;
	int min_work_end_a <- 14;
	int max_work_end_a <- 22;
	int min_work_start_c <- 9;
	int max_work_start_c <- 9;
	int min_work_end_c <- 14;
	int max_work_end_c <- 14;

	// The value of the day_time variable is automatically computed at each simulation step and is equals to 
	// "time (the simulation step) modulo 144" (one day is decomposed in 144 simulation steps).          
	//    int day_time update: time mod 144 ;
	//    int min_work_start <- 36;
	//    int max_work_start <- 60;
	//    int min_work_end <- 84; 
	//    int max_work_end <- 132; 
	float min_speed <- 50.0;
	float max_speed <- 100.0;
	graph the_graph;
	init
	{
		create building from: shape_file_buildings with: [type:: string(read('NATURE'))]
		{
			if type = 'Industrial'
			{
				color <- rgb('pink');
			}

			if type = 'School'
			{
				color <- rgb('black');
			}

		}

		create road from: shape_file_roads;
		map<road, float> weights_map <- road as_map (each::(shape.perimeter));
		the_graph <- as_edge_graph(road) with_weights weights_map;
		list<building> residential_buildings <- building where (each.type = 'Residential');
		list<building> industrial_buildings <- building where (each.type = 'Industrial');
		list<building> school_buildings <- building where (each.type = 'School');
		create adults number: nb_adults
		{
			speed <- min_speed + rnd(max_speed - min_speed);
			start_work <- min_work_start_a + rnd(max_work_start_a - min_work_start_a);
			end_work <- min_work_end_a + rnd(max_work_end_a - min_work_end_a);
			living_place <- one_of(residential_buildings);
			working_place <- one_of(industrial_buildings);
			location <- any_location_in(living_place);
		}

		create children number: nb_children
		{
			speed <- min_speed + rnd(max_speed - min_speed);
			start_work <- min_work_start_c + rnd(max_work_start_c - min_work_start_c);
			end_work <- min_work_end_c + rnd(max_work_end_c - min_work_end_c);
			living_place <- one_of(residential_buildings);
			working_place <- one_of(school_buildings);
			location <- any_location_in(living_place);
		}

		create elderly number: nb_elderly
		{
			living_place <- one_of(residential_buildings);
			location <- any_location_in(living_place);
		}

	}

	reflex update_graph
	{
		map<road, float> weights_map <- road as_map (each::(each.shape.perimeter));
		the_graph <- the_graph with_weights weights_map;
	}

	reflex save_trajectories when: cycle = cycle_to_save
	{
		//adults case
		ask adults
		{
			loop t over: trajectories {
				create trajectory with: [shape::t, agent_name::name];
			}
		}
		ask children
		{
			loop t over: trajectories {
				create trajectory with: [shape::t, agent_name::name];
			}
		}
		save trajectory to:"trajectory.shp" type:"shp" with: [agent_name::"agent"];
		ask trajectory {do die;}
	}

}

species building
{
	string type;
	rgb color <- # blue;
	aspect base
	{
		draw shape color: color;
	}

}

species road
{
	rgb color <- # black;
	aspect geom
	{
		draw shape color: color;
	}

}

species trajectory {
	string agent_name;
}

species adults skills: [moving]
{
	rgb color <- # yellow;
	building living_place <- nil;
	building working_place <- nil;
	int start_work;
	int end_work;
	string objective;
	point the_target <- nil;
	list<geometry> trajectories;
	reflex time_to_work when: day_time = start_work
	{
		objective <- 'working';
		the_target <- any_location_in(working_place);
	}

	reflex time_to_go_home when: day_time = end_work
	{
		objective <- 'go home';
		the_target <- any_location_in(living_place);
	}

	reflex move when: the_target != nil
	{
		path path_followed <- self goto [target::the_target, on::the_graph, return_path::true];
		list<geometry> segments <- path_followed.segments;
		loop line over: segments
		{
			trajectories << line;
		
			float dist <- line.perimeter;
			road ag <- road(path_followed agent_from_geometry line);
		}

		switch the_target
		{
			match location
			{
				the_target <- nil;
			}

		}

	}

	aspect base
	{
		draw circle(7) color: color;
	}

}

species children parent: adults
{
	rgb color <- # red;
	aspect base
	{
		draw circle(5) color: color;
	}

}

species elderly
{
	rgb color <- # green;
	building living_place <- nil;
	string objective;
	point the_target <- nil;
	aspect base
	{
		draw circle(5) color: color;
	}

}

experiment dim_traffic_example type: gui
{
	parameter 'Shapefile for the buildings:' var: shape_file_buildings category: 'GIS';
	parameter 'Shapefile for the roads:' var: shape_file_roads category: 'GIS';
	//    parameter 'Shapefile for the bounds:' var: shape_file_bounds category: 'GIS' ;
	parameter 'Number of adults agents' var: nb_adults category: 'adults';
	parameter 'Number of children agents' var: nb_children category: 'children';
	parameter 'Number of elderly agents' var: nb_elderly category: 'elderly';
	parameter 'Earliest hour to start work' var: min_work_start_a category: 'adults';
	parameter 'Latest hour to start work' var: max_work_start_a category: 'adults';
	parameter 'Earliest hour to end work' var: min_work_end_a category: 'adults';
	parameter 'Latest hour to end work' var: max_work_end_a category: 'adults';
	parameter 'minimal speed' var: min_speed category: 'adults';
	parameter 'maximal speed' var: max_speed category: 'adults';
	parameter 'Earliest hour to start work' var: min_work_start_c category: 'children';
	parameter 'Latest hour to start work' var: max_work_start_c category: 'children';
	parameter 'Earliest hour to end work' var: min_work_end_c category: 'children';
	parameter 'Latest hour to end work' var: max_work_end_c category: 'children';
	parameter 'minimal speed' var: min_speed category: 'adults';
	parameter 'maximal speed' var: max_speed category: 'adults';
	output
	{
		display dim_traffic_example refresh_every: 1
		{
			species building aspect: base;
			species road aspect: geom;
			species adults aspect: base;
			species children aspect: base;
			species elderly aspect: base;
		}

		display chart_display refresh_every: 10
		{
			chart name: 'adults Objectif' type: pie background: # gray style: exploded size: { 1, 1 } position: { 0, 0 }
			{
				data name: 'Working' value: adults count (each.objective = 'working') color: # green;
				data name: 'Staying home' value: adults count (each.objective = 'go home') color: # blue;
			}

			chart name: 'children Objectif' type: pie background: # gray style: exploded size: { 1, 1 } position: { 0, 0 }
			{
				data name: 'Working' value: adults count (each.objective = 'working') color: # green;
				data name: 'Staying home' value: adults count (each.objective = 'go home') color: # blue;
			}

		}

	}

}