// --- 1. YOUR EXACT SPECS (INCHES) ---
ancho_total   = 35.5; 
alto_total    = 38.75;   
fondo_box     = 12.25;    
t_plywood     = 0.75;     
t_backer      = 0.25;     
t_face_maple  = 0.75;     
rabbet_d      = 0.125;    

// --- 2. YOUR DOOR SPECS (EXACT) ---
door_w        = 17.5625; 
door_h        = 38.625;  
frame_w       = 2.25;     
panel_w       = 14.0625; 
panel_h       = 35.125;
t_door        = 0.75;     

// --- 3. ANIMATION & EXPLODE CONTROLS ---
explode       = 0;     // Set to 0 for built, 5-10 for exploded view
show_labels   = (explode > 0); // Only show labels when exploded
Door_Open_Angle = 15;

// --- 4. COLORS ---
color_plywood = [0.82, 0.71, 0.55]; 
color_maple   = [0.45, 0.29, 0.07]; 

$fn = 60;

// --- 5. HELPER: 3D LABELS ---
module part_label(txt) {
    if (show_labels) {
        translate([0, 0, 2]) // Float above part
        color("black")
        linear_extrude(0.1)
            text(txt, size=1.5, halign="center", font="Arial:style=Bold");
    }
}

module shaker_door() {
    color(color_maple) union() {
        difference() {
            cube([door_w, t_door, door_h]); 
            translate([frame_w, -0.1, frame_w])
                cube([door_w - (frame_w * 2), 0.8, door_h - (frame_w * 2)]);
        }
        translate([frame_w - 0.25, 0.25, frame_w - 0.25]) 
            color(color_plywood) cube([panel_w, 0.25, panel_h]);
    }
}

module assembly() {
    // A. SIDES
    color(color_plywood) {
        // Left Side
        translate([-explode, 0, 0]) {
            difference() {
                cube([t_plywood, fondo_box, alto_total]);
                translate([t_plywood - rabbet_d, -0.1, alto_total - t_plywood]) cube([rabbet_d+0.1, fondo_box+0.2, t_plywood+0.1]);
                translate([t_plywood - rabbet_d, -0.1, -0.1]) cube([rabbet_d+0.1, fondo_box+0.2, t_plywood+0.1]);
            }
            translate([t_plywood/2, fondo_box/2, alto_total]) rotate([90,0,0]) part_label("SIDE L");
        }
        // Right Side
        translate([ancho_total - t_plywood + explode, 0, 0]) {
            difference() {
                cube([t_plywood, fondo_box, alto_total]);
                translate([-0.1, -0.1, alto_total - t_plywood]) cube([rabbet_d+0.1, fondo_box+0.2, t_plywood+0.1]);
                translate([-0.1, -0.1, -0.1]) cube([rabbet_d+0.1, fondo_box+0.2, t_plywood+0.1]);
            }
            translate([t_plywood/2, fondo_box/2, alto_total]) rotate([90,0,0]) part_label("SIDE R");
        }
    }

    // B. TOP & BOTTOM
    w_horiz = ancho_total - (2 * (t_plywood - rabbet_d));
    horiz_x = t_plywood - rabbet_d;
    color(color_plywood) {
        // Bottom
        translate([horiz_x, 0, -explode]) {
            cube([w_horiz, fondo_box, t_plywood]);
            translate([w_horiz/2, fondo_box/2, -2]) rotate([90,0,0]) part_label("BOTTOM");
        }
        // Top
        translate([horiz_x, 0, alto_total - t_plywood + explode]) {
            cube([w_horiz, fondo_box, t_plywood]);
            translate([w_horiz/2, fondo_box/2, t_plywood + 2]) rotate([90,0,0]) part_label("TOP");
        }
    }

    // C. THE BACKER
    translate([t_plywood, fondo_box - t_backer + (explode*1.5), t_plywood]) {
        color([0.7, 0.6, 0.4]) cube([ancho_total - (2*t_plywood), t_backer, alto_total - (2*t_plywood)]);
        translate([(ancho_total-t_plywood*2)/2, 0, alto_total/2]) rotate([90,0,0]) part_label("BACKER");
    }

    // D. THE FACE FRAME
    color(color_maple)
    translate([0, -t_face_maple - explode, 0]) {
        difference() {
            cube([ancho_total, t_face_maple, alto_total]);
            translate([t_plywood, -0.1, t_plywood])
                cube([ancho_total - (2 * t_plywood), t_face_maple+0.2, alto_total - (2 * t_plywood)]);
        }
        translate([ancho_total/2, 0, alto_total+1]) rotate([90,0,0]) part_label("FACE FRAME");
    }

    // E. THE DOORS
    gap = (ancho_total - (2 * door_w)) / 3;
    d_exp = explode * 2.5; 

    translate([gap, -(t_face_maple + t_door) - d_exp, (alto_total - door_h)/2])
    rotate([0, 0, -Door_Open_Angle]) shaker_door();

    translate([ancho_total - gap, -(t_face_maple + t_door) - d_exp, (alto_total - door_h)/2])
    rotate([0, 0, Door_Open_Angle]) translate([-door_w, 0, 0]) shaker_door();
}

// --- 6. ECHO CUT LIST TO CONSOLE ---
echo("--- SHOP CUT LIST ---");
echo(str("SIDE PLY (2): ", alto_total, " x ", fondo_box));
echo(str("TOP/BOT PLY (2): ", ancho_total - (2 * (t_plywood - rabbet_d)), " x ", fondo_box));
echo(str("DOOR STILES (4): ", door_h, " x ", frame_w));
echo(str("DOOR RAILS (4): ", door_w - (2 * frame_w), " x ", frame_w));

// --- RENDER ---
assembly();
translate([0, 0, alto_total + 0.125]) assembly();