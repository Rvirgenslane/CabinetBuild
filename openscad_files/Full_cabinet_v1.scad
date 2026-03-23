// --- 1. YOUR EXACT SPECS (INCHES) ---
ancho_total   = 35.5; 
alto_total    = 38.75;   
fondo_box     = 12.25;    
t_plywood     = 0.75;     
t_backer      = 0.25;     
t_face_maple  = 0.75;     
rabbet_d      = 0.125;    

// --- 2. YOUR DOOR SPECS (EXACT) ---
door_w        = 17 + 9/16; // 17.5625"
door_h        = 38 + 5/8;  // 38.625"
frame_w       = 2.25;      // 2-1/4" Maple frames
panel_w       = 14 + 1/16; // Includes the 1/2" tongue
panel_h       = 35 + 1/8;
t_door        = 0.75;      // 3/4" Thick maple

Door_Open_Angle = 15;      // Change to 90 to see inside!

// --- 3. COLORS ---
color_plywood = [0.82, 0.71, 0.55]; // Light Brown
color_maple   = [0.45, 0.29, 0.07]; // Dark Brown

$fn = 60;

module shaker_door() {
    // Frame (Dark Maple)
    color(color_maple) union() {
        difference() {
            cube([door_w, t_door, door_h]); 
            // The cutout for the panel
            translate([frame_w, -0.1, frame_w])
                cube([door_w - (frame_w * 2), 0.6, door_h - (frame_w * 2)]);
        }
        // The 1/4" Insert (Light Plywood color for contrast)
        translate([frame_w - 0.25, 0.25, frame_w - 0.25]) 
            color(color_plywood) cube([panel_w, 0.25, panel_h]);
    }
}

module assembly() {
    // A. THE PLYWOOD BOX (With 1/8" Internal Rabbets)
    color(color_plywood) {
        // Left Side
        difference() {
            cube([t_plywood, fondo_box, alto_total]);
            translate([t_plywood - rabbet_d, -0.1, alto_total - t_plywood]) cube([rabbet_d+0.1, fondo_box+0.2, t_plywood+0.1]);
            translate([t_plywood - rabbet_d, -0.1, -0.1]) cube([rabbet_d+0.1, fondo_box+0.2, t_plywood+0.1]);
        }
        // Right Side
        translate([ancho_total - t_plywood, 0, 0])
        difference() {
            cube([t_plywood, fondo_box, alto_total]);
            translate([-0.1, -0.1, alto_total - t_plywood]) cube([rabbet_d+0.1, fondo_box+0.2, t_plywood+0.1]);
            translate([-0.1, -0.1, -0.1]) cube([rabbet_d+0.1, fondo_box+0.2, t_plywood+0.1]);
        }
        // Top & Bottom
        w_horiz = ancho_total - (2 * (t_plywood - rabbet_d));
        horiz_x = t_plywood - rabbet_d;
        translate([horiz_x, 0, 0]) cube([w_horiz, fondo_box, t_plywood]);
        translate([horiz_x, 0, alto_total - t_plywood]) cube([w_horiz, fondo_box, t_plywood]);
    }

    // B. THE 1/4" BACKER
    translate([t_plywood, fondo_box - t_backer, t_plywood])
        color([0.7, 0.6, 0.4]) cube([ancho_total - (2*t_plywood), t_backer, alto_total - (2*t_plywood)]);

    // C. THE 3/4" MAPLE FACE FRAME
    color(color_maple)
    translate([0, -t_face_maple, 0])
    difference() {
        cube([ancho_total, t_face_maple, alto_total]);
        translate([t_plywood, -0.1, t_plywood])
            cube([ancho_total - (2 * t_plywood), t_face_maple+0.2, alto_total - (2 * t_plywood)]);
    }

    // D. THE DOORS (Sitting on top of the Face Frame)
    // Gap calculation for centered doors: (Total Width - (2 * Door Width)) / 3 gaps
    gap = (ancho_total - (2 * door_w)) / 3;

    // Left Door
    translate([gap, -(t_face_maple + t_door), (alto_total - door_h)/2])
    rotate([0, 0, -Door_Open_Angle])
        shaker_door();

    // Right Door
    translate([ancho_total - gap, -(t_face_maple + t_door), (alto_total - door_h)/2])
    rotate([0, 0, Door_Open_Angle])
    translate([-door_w, 0, 0])
        shaker_door();
}

// --- RENDER ---
assembly();
translate([0, 0, alto_total + 0.125]) assembly();