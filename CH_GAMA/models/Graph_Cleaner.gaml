/**
* Name: clean_road_network
* Author: Patrick Taillandier
* Description: shows how GAMA can help to clean network data before using it to make agents move on it
* Tags: gis, shapefile, graph, clean
*/

model clean_road_network

global {
	//Shapefile of the roads
	file geo_file <- geojson_file("../includes/car_1.geojson", 4326);
	
	//Shape of the environment
	geometry shape <- envelope(geo_file);
	
	
	//clean or not the data
	bool clean_data <- true parameter: true;
	
	//tolerance for reconnecting nodes
	float tolerance <- 1.0 parameter: true;
	
	//if true, split the lines at their intersection
	bool split_lines <- true parameter: true;
	
	//if true, keep only the main connected components of the network
	bool reduce_to_main_connected_components <- true parameter: true;
	
	string legend <- not clean_data ? "Raw data" : ("Clean data : tolerance: " + tolerance + "; split_lines: " + split_lines + " ; reduce_to_main_connected_components:" + reduce_to_main_connected_components );
	
	list<list<point>> connected_components ;
	list<rgb> colors;
	graph road_network_clean;
			
	init {
		write shape.width;
		//clean data, with the given options
		//list<geometry> clean_lines <- clean_data ? clean_network(road_shapefile.contents,tolerance,split_lines,reduce_to_main_connected_components) : road_shapefile.contents;
		list<geometry> clean_lines <- clean_data ? clean_network(geo_file.contents,tolerance,split_lines,reduce_to_main_connected_components) : geo_file.contents;
		write length(clean_lines);
		//create road from the clean lines
		create road from: clean_lines;
		
		//build a network from the road agents
		road_network_clean <- as_edge_graph(road);
		
		//computed the connected components of the graph (for visualization purpose)
		connected_components <- list<list<point>>(connected_components_of(road_network_clean));
		loop times: length(connected_components) {colors << rnd_color(255);}
		create people number:100{
			location<-any_location_in(one_of(road));
			target <-any_location_in(one_of(road));
		}
    }
    
    reflex when: cycle=1{
    	save road to: "../includes/car_clean.geojson" type:json;
    }
}

//Species to represent the roads
species road {
	aspect default {
		draw shape color: #darkgray;
	}
}

species people skills:[moving]{
	point target;
	reflex move{
		//do goto target:target on:road_network_clean speed:world.shape.width*0.0001;
		do wander on:road_network_clean speed:world.shape.width*0.0001;
	}
	
	aspect default{
		draw circle(world.shape.width*0.005) color:#red;
	}
}

experiment clean_network type: gui {
	
	output {
		display network background:#black{
			
			species road ;
			species people;
			graphics "connected components" {
				loop i from: 0 to: length(connected_components) - 1 {
					loop j from: 0 to: length(connected_components[i]) - 1 {
						draw circle(200) color: colors[i] at: connected_components[i][j];	
					}
				}
			}
		}
	}
}
