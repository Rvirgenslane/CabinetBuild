// --- 1. YOUR EXACT SPECS (INCHES) ---
ancho_total   = 35.5; 
alto_total    = 38.75;   
fondo_box     = 12.25;    
t_plywood     = 0.75;     
t_backer      = 0.25;     
t_face_maple  = 0.75;     
rabbet_d      = 0.125;    // Depth for Top/Bottom joints

// --- BACKER RABBET SPECS ---
backer_rab_w  = 0.25;     // Width of the channel (matches backer thickness)
backer_rab_d  = 0.375;    // Depth of the channel (3/8")

// --- MOUNTING BRACKET ---
h_bracket     = 4.0;      
t_bracket     = 0.75;     

// --- 2. YOUR DOOR SPECS ---
door_w        = 17.5625; 
door_h        = 38.625;  
frame_w       = 2.25;     
t_door        = 0.75;     

explode       = 0; 
show_labels   = (explode > 0);
Door_Open_Angle = 120;

// --- 3. COLORS ---
color_plywood = [0.82, 0.71, 0.55]; 
color_maple   = [0.45, 0.29, 0.07]; 

$fn = 60;

module shaker_door() {
    color(color_maple) union() {
        difference() {
            cube([door_w, t_door, door_h]); 
            translate([frame_w, -0.1, frame_w])
                cube([door_w - (frame_w * 2), 0.8, door_h - (frame_w * 2)]);
        }
        translate([frame_w - 0.25, 0.25, frame_w - 0.25]) 
            color(color_plywood) cube([14.0625, 0.25, 35.125]);
    }
}

module assembly() {
    // A. SIDES (With Dual Rabbets: Top/Bottom and Backer)
    color(color_plywood) {
        // Left Side
        translate([-explode, 0, 0]) difference() {
            cube([t_plywood, fondo_box, alto_total]);
            // Top/Bottom Rabbets (1/8" deep)
            translate([t_plywood - rabbet_d, -0.1, alto_total - t_plywood]) cube([rabbet_d+0.1, fondo_box+0.2, t_plywood+0.1]);
            translate([t_plywood - rabbet_d, -0.1, -0.1]) cube([rabbet_d+0.1, fondo_box+0.2, t_plywood+0.1]);
            // Backer Rabbet (3/8" deep, 1/4" wide)
            translate([t_plywood - backer_rab_d, fondo_box - backer_rab_w, -0.1]) 
                cube([backer_rab_d + 0.1, backer_rab_w + 0.1, alto_total + 0.2]);
        }
        // Right Side
        translate([ancho_total - t_plywood + explode, 0, 0]) difference() {
            cube([t_plywood, fondo_box, alto_total]);
            // Top/Bottom Rabbets (1/8" deep)
            translate([-0.1, -0.1, alto_total - t_plywood]) cube([rabbet_d+0.1, fondo_box+0.2, t_plywood+0.1]);
            translate([-0.1, -0.1, -0.1]) cube([rabbet_d+0.1, fondo_box+0.2, t_plywood+0.1]);
            // Backer Rabbet (3/8" deep, 1/4" wide)
            translate([-0.1, fondo_box - backer_rab_w, -0.1]) 
                cube([backer_rab_d + 0.1, backer_rab_w + 0.1, alto_total + 0.2]);
        }
    }

    // B. TOP & BOTTOM
    w_horiz = ancho_total - (2 * (t_plywood - rabbet_d));
    horiz_x = t_plywood - rabbet_d;
    color(color_plywood) {
        translate([horiz_x, 0, -explode]) cube([w_horiz, fondo_box, t_plywood]);
        translate([horiz_x, 0, alto_total - t_plywood + explode]) cube([w_horiz, fondo_box, t_plywood]);
    }

    // C. THE BACKER (Fits into the 3/8" deep rabbets)
    w_backer = ancho_total - (2 * (t_plywood - backer_rab_d));
    translate([t_plywood - backer_rab_d, fondo_box - backer_rab_w + (explode*1.5), t_plywood]) {
        color([0.7, 0.6, 0.4]) cube([w_backer, t_backer, alto_total - (2*t_plywood)]);
    }

    // D. MOUNTING BRACKET (Top Rail)
    // Needs to be slightly narrower to fit between the side panels *inside* the rabbet area
    w_bracket = ancho_total - (2 * t_plywood);
    color(color_maple) {
        translate([t_plywood, fondo_box - backer_rab_w - t_bracket + (explode*2), alto_total - t_plywood - h_bracket]) {
            cube([w_bracket, t_bracket, h_bracket]);
        }
    }

    // E. FACE FRAME & DOORS
    color(color_maple) translate([0, -t_face_maple - explode, 0])
        difference() {
            cube([ancho_total, t_face_maple, alto_total]);
            translate([t_plywood, -0.1, t_plywood]) cube([ancho_total - (2 * t_plywood), t_face_maple+0.2, alto_total - (2 * t_plywood)]);
        }

    gap = (ancho_total - (2 * door_w)) / 3;
    d_exp = explode * 2.5; 
    translate([gap, -(t_face_maple + t_door) - d_exp, (alto_total - door_h)/2]) rotate([0, 0, -Door_Open_Angle]) shaker_door();
    translate([ancho_total - gap, -(t_face_maple + t_door) - d_exp, (alto_total - door_h)/2]) rotate([0, 0, Door_Open_Angle]) translate([-door_w, 0, 0]) shaker_door();
}

// --- 6. ECHO CUT LIST ---
echo("--- SHOP CUT LIST (PER UNIT) ---");
echo(str("SIDE PLY (2): ", alto_total, " x ", fondo_box, " (Rabbet back edge 1/4\"x3/8\")"));
echo(str("TOP/BOT PLY (2): ", ancho_total - (2 * (t_plywood - rabbet_d)), " x ", fondo_box));
echo(str("BACKER (1): ", ancho_total - (2 * (t_plywood - backer_rab_d)), " x ", alto_total - (2 * t_plywood)));
echo(str("TOP BRACKET (1): ", ancho_total - (2 * t_plywood), " x ", h_bracket));

// --- RENDER ---
assembly();
translate([0, 0, alto_total + 0.125]) assembly();