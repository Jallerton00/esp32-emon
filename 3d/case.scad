/* [Rendering options] */
// Show placeholder PCB in OpenSCAD preview
show_pcb = true;
// Lid mounting method
lid_model = "cap"; // [cap, inner-fit]
// Conditional rendering
render = "case"; // [all, case, lid]


/* [Dimensions] */
// Height of the PCB mounting stand-offs between the bottom of the case and the PCB
standoff_height = 5;
// PCB thickness
pcb_thickness = 1.6;
// Bottom layer thickness
floor_height = 1.2;
// Case wall thickness
wall_thickness = 1.2;
// Space between the top of the PCB and the top of the case
headroom = 5.0;

/* [M3 screws] */
// Outer diameter for the insert
insert_M3_diameter = 3.77;
// Depth of the insert
insert_M3_depth = 4.5;

/* [Hidden] */
$fa=$preview ? 10 : 4;
$fs=0.2;
inner_height = floor_height + standoff_height + pcb_thickness + headroom;

module wall (thickness, height) {
    linear_extrude(height, convexity=10) {
        difference() {
            offset(r=thickness)
                children();
            children();
        }
    }
}

module bottom(thickness, height) {
    linear_extrude(height, convexity=3) {
        offset(r=thickness)
            children();
    }
}

module lid(thickness, height, edge) {
    linear_extrude(height, convexity=10) {
        offset(r=thickness)
            children();
    }
    translate([0,0,-edge])
    difference() {
        linear_extrude(edge, convexity=10) {
                offset(r=-0.2)
                children();
        }
        translate([0,0, -0.5])
         linear_extrude(edge+1, convexity=10) {
                offset(r=-1.2)
                children();
        }
    }
}


module box(wall_thick, bottom_layers, height) {
    if (render == "all" || render == "case") {
        translate([0,0, bottom_layers])
            wall(wall_thick, height) children();
        bottom(wall_thick, bottom_layers) children();
    }
    
    if (render == "all" || render == "lid") {
        translate([0, 0, height+bottom_layers+0.1])
        lid(wall_thick, bottom_layers, lid_model == "inner-fit" ? headroom-2.5: bottom_layers) 
            children();
    }
}

module mount(drill, space, height) {
    translate([0,0,height/2])
        difference() {
            cylinder(h=height, r=(space/2), center=true);
            cylinder(h=(height*2), r=(drill/2), center=true);
            
            translate([0, 0, height/2+0.01])
                children();
        }
        
}

module connector(min_x, min_y, max_x, max_y, height) {
    size_x = max_x - min_x;
    size_y = max_y - min_y;
    translate([(min_x + max_x)/2, (min_y + max_y)/2, height/2])
        cube([size_x, size_y, height], center=true);
}

module Cutout_Pinheader_substract(width, height) {
    translate([0, 0, height/2+0.1])
        cube([10, width+0.2, height+0.2], center=true);
}

module pcb() {
    thickness = 1.6;

    color("#009900")
    difference() {
        linear_extrude(thickness) {
            polygon(points = [[142.8,26], [186.6,26], [187.74805011484045,26.228361716195526], [188.72132,26.87868], [189.3716382838045,27.851949885159563], [189.6,29], [189.6,78.8], [189.3716382838045,79.94805011484043], [188.72132,80.92132], [187.74805011484045,81.57163828380446], [186.6,81.8], [142.8,81.8], [141.65194988515958,81.57163828380448], [140.67868,80.92132], [140.02836171619552,79.94805011484044], [139.8,78.8], [139.8,29], [140.02836171619555,27.851949885159563], [140.67868,26.87868], [141.65194988515958,26.228361716195526], [142.8,26]]);
        }
    translate([162.16, 30.12, -1])
        cylinder(thickness+2, 1.5, 1.5);
    translate([186.68, 30.12, -1])
        cylinder(thickness+2, 1.5, 1.5);
    translate([162.17, 77.08, -1])
        cylinder(thickness+2, 1.5, 1.5);
    translate([186.68, 77.08, -1])
        cylinder(thickness+2, 1.5, 1.5);
    }
}

module case_outline() {
    polygon(points = [[137.75,81.75], [137.75,81.75], [137.9022405353483,82.51536709688666], [138.335786,83.164214], [138.98463290311335,83.59775946465166], [139.75,83.75], [189.6,83.75], [190.36536709688664,83.59775946465169], [191.014214,83.164214], [191.44775946465165,82.51536709688665], [191.6,81.75], [191.6,26], [191.44775946465165,25.23463290311337], [191.014214,24.585786], [190.36536709688664,24.152240535348312], [189.6,24], [139.8,24], [139.798269,24], [139.03330735112678,24.152075307969977], [138.384666,24.585163], [137.95099989947727,25.23342547040266], [137.79827,25.998268], [137.75,81.75]]);
}

module Insert_M3() {
    translate([0, 0, -insert_M3_depth])
        cylinder(insert_M3_depth, insert_M3_diameter/2, insert_M3_diameter/2);
    translate([0, 0, -0.3])
        cylinder(0.3, insert_M3_diameter/2, insert_M3_diameter/2+0.3);
}

rotate([render == "lid" ? 180 : 0, 0, 0])
scale([1, -1, 1])
translate([-164.675, -53.875, 0]) {
    pcb_top = floor_height + standoff_height + pcb_thickness;

    difference() {
        box(wall_thickness, floor_height, inner_height) {
            case_outline();
        }

    translate([0, 0, -1])
    #linear_extrude(floor_height+2, convexity=10) 
        polygon(points = [[189.6,83.75], [189.6,83.75]]);

    // J2  DC Barrel Jack with an internal switch
    translate([154.8, 73.6, pcb_top])
    rotate([0, 0, 0])
        #connector(-13.7,-4.505425,0.8,4.5,5.2);

    // U1  
    translate([174.4, 53.6, pcb_top])
    rotate([0, 0, -180])
        #connector(-14.28,-25.475,14.23,25.475,3.2);

    // Substract: Cutout for horizontal 2.54mm 10.16x2.54 pinheader
    translate([140.83, 34.02, pcb_top])
        Cutout_Pinheader_substract(width=10.16, height=2.54);

    }

    if (show_pcb && $preview) {
        translate([0, 0, floor_height + standoff_height])
            pcb();
    }

    if (render == "all" || render == "case") {
        // REF** [('M3', 3)]
        translate([162.16, 30.12, floor_height])
        mount(3, 6.5, standoff_height)
            Insert_M3();
        // REF** [('M3', 3)]
        translate([186.68, 30.12, floor_height])
        mount(3, 6.5, standoff_height)
            Insert_M3();
        // REF** [('M3', 3)]
        translate([162.17, 77.08, floor_height])
        mount(3, 6.5, standoff_height)
            Insert_M3();
        // REF** [('M3', 3)]
        translate([186.68, 77.08, floor_height])
        mount(3, 6.5, standoff_height)
            Insert_M3();
    }
}
