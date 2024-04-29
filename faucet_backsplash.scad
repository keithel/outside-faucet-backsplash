// Size of the backsplash block (WxH mm)
block_sz = [133, 81]; // 135-137 x 82-83 mm
// (mm)
block_thickness = 25.4;
// (mm)
pipe_radius = 12.5; // mm
pipe_radius_tolerance = 2.5; // mm
// Offset of the two screws from center (mm)
screwhole_center_offset=25; // mm
// (mm)
screwhole_dia = 6; // mm
screwhole_countersink_dia = 8.3; // mm
screwhole_countersink_depth = 4; // mm
// Split the model in two with dovetail joint
split = false; // Split the model in two
// Separate the two halves
separate_split = true; // Separate the split parts
$fn=100;

// Todo:
// 4mm narrower - DONE - 137 down to 133.
// Center the cut on the faucet circle - DONE
// screwholes should be 25mm from center - DONE
// Screwholes need increased diameter for the screws - inside threads is 3.4mm, shaft above threads is 3.8mm, but test print with 4mm hole didn't fit the screw. DONE - 5mm now.
// Increase screwholes again - DONE - 6mm
// Make shorter - DONE - 83mm down to 81mm


use </home/kyzik/Documents/3D models/openscad_libs/dovetail.scad>

module pipeblock() {
    scrhole_co = screwhole_center_offset;
    sd = screwhole_dia;
    difference() {
        linear_extrude(height = block_thickness)
            difference() {
                square(block_sz);
                translate([block_sz.x/2, block_sz.y/2, 0])
                    union() {
                        circle(pipe_radius + pipe_radius_tolerance);
                        translate([scrhole_co,0,0])
                        circle(d=sd);
                        translate([-scrhole_co,0,0])
                        circle(d=sd);
                    }
            }
        // Countersunk screwholes
        csd = screwhole_countersink_depth;
        csr = screwhole_countersink_dia/2;
        translate([block_sz.x/2, block_sz.y/2, block_thickness-csd/2]) {
            for(i=[0:1]) {
                translate([(i?-1:1)*scrhole_co,0,0])
                    cylinder(h=csd, r1=sd/2, r2=csr, center=true);
            }
        }
    }
    
}

position = [block_sz.y/2,block_sz.x/2,0];
dimension = [block_sz.y, block_sz.x, block_sz.x];
teeth = [3, 8, 0.2];

module cutter_no_middleteeth(male=false) {
    if(male)
    {
        union() {
            cutter(position=position, dimension=dimension, teeths=teeth, male=male);
            translate([dimension.x/3, dimension.y/2-teeth[1]/2-teeth[2]*1.5,-dimension.z/2])
            cube([dimension.x/3, teeth[1], dimension.z]);
        }
    } else {
        difference() {
            cutter(position=position, dimension=dimension, teeths=teeth, male=male);
            translate([dimension.x/3, dimension.y/2-teeth[1]/2-0.1,-dimension.z/2-0.5])
            cube([dimension.x/3, teeth[1], dimension.z+1]);
        }
    }
}

module split_pipeblock(separate=false) {
    cut_rotation=20;
    xoffset=9+(block_thickness/tan(90-cut_rotation));
    translate([separate ? 30 : 0,0,0]) {
        difference() {
        intersection() {
            pipeblock();
            translate([block_sz.x+xoffset,0,block_thickness*2])
            rotate([cut_rotation,0,90])
            translate([0,0,-block_thickness*3])
            cutter_no_middleteeth(male=true);
        }
        translate([block_sz.x/2-(block_thickness/tan(90-cut_rotation))+3, block_sz.y/2, 0])
            linear_extrude(height = block_thickness-12)
                square([pipe_radius, pipe_radius*2], center=true);
        }
    }

    intersection() {
        pipeblock();
        translate([block_sz.x+xoffset,0,block_thickness*2])
        rotate([cut_rotation,0,90])
        translate([0,0,-block_thickness*3])
        cutter_no_middleteeth(male=false);
    }
}


//difference() { // This is for making test prints of just the screwhole
if(split)
    split_pipeblock(separate=separate_split);
else
    pipeblock();
    
// This is for making test prints of just the screwhole
//linear_extrude(height=block_thickness+1)
//    translate([block_sz.x/2-screwhole_center_offset, block_sz.y/2,0])
//        difference() {
//        circle(r=200);
//        circle(r=6);
//        }
//}




if (split && separate_split) {
#translate([0,-1,0])
    square([block_sz.x/2-teeth[1]+7.7955,1], center=false);
#translate([block_sz.x/2+(separate_split?30:0)+0.48715,-1,0])
    square([block_sz.x/2-teeth[1]+7.5,1], center=false);

#translate([block_sz.x/2-teeth[1]+7.7955,block_sz.y/2,0]) {
    square([1,pipe_radius*2], center=true);
    translate([-12.25,0,0])
        square([12.75,1], center=false);
}
#translate([block_sz.x/2-teeth[1]+7.7955+0.5+(separate_split?30:0),block_sz.y/2,0]) {
    square([1,pipe_radius*2], center=true);
    translate([-0.5,0,0])
        square([12.75,1], center=false);
}
}