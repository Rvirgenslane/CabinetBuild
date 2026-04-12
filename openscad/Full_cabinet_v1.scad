// --- 1. YOUR EXACT SPECS (INCHES) ---
ancho_total   = 35.5; 
alto_total    = 38.75;   
fondo_box     = 12.25;    
t_plywood     = 0.75;     
t_backer      = 0.25;     
t_face_maple  = 0.75;     
rabbet_d      = 0.125; 

// --- BACKER RABBET SPECS ---
backer_rab_w  = 0.25;     
backer_rab_d  = 0.375;    

// --- MOUNTING BRACKET ---
h_bracket     = 3.0;      
t_bracket     = 0.75;     

// --- 2. YOUR DOOR SPECS ---
door_w        = 17.5625; 
door_h        = 38.625;  
frame_w       = 2.25;     
t_door        = 0.75;     // Thickness of Maple Frame
t_panel       = 0.25;     // Thickness of Plywood Insert
panel_nest_d  = 0.125;    // Recess depth from front face

// Calculated Door Panel (includes 1/4" tongue for the grooves)
panel_w_calc  = door_w - (frame_w * 2) + 0.5;
panel_h_calc  = door_h - (frame_w * 2) + 0.5;

explode       = 0; 
show_labels   = (explode > 0);
Door_Open_Angle = 90;

// --- 3. COLORS ---
color_plywood = [0.82, 0.71, 0.55]; 
color_maple   = [0.45, 0.29, 0.07]; 

$fn = 60;

// --- 4. HELPER: MEASUREMENT LABELS ---
module dim_label(txt, loc=[0,0,0], rot=[90,0,0]) {
    if (show_labels) {
        translate(loc) rotate(rot)
        color("DimGray") linear_extrude(0.1)
            text(str(txt, "\""), size=1.2, halign="center", font="Arial:style=Bold");
    }
}

// --- 5. DOOR MODULE ---
module shaker_door(is_right_door = false) {
    rail_w = door_w - (frame_w * 2);
    pivot_x = is_right_door ? door_w : 0;
    
    rotate([0, 0, is_right_door ? Door_Open_Angle : -Door_Open_Angle])
    translate([-pivot_x, 0, 0])
    union() {
        // THE MAPLE FRAME
        color(color_maple) difference() {
            cube([door_w, t_door, door_h]); 
            // The cutout for the panel
            translate([frame_w, -0.1, frame_w])
                cube([door_w - (frame_w * 2), t_door + 0.2, door_h - (frame_w * 2)]);
        }
        
        // THE PLYWOOD PANEL (Nested 1/8" from the face)
        translate([frame_w - 0.25, panel_nest_d, frame_w - 0.25]) 
            color(color_plywood) cube([panel_w_calc, t_panel, panel_h_calc]);

        if (show_labels) {
            dim_label(door_h, [pivot_x + (is_right_door ? -1 : 1), -1, door_h/2]);
            dim_label(rail_w, [door_w/2, -1, frame_w/2]);
        }
    }
}

module assembly() {
    // A. SIDES
    color(color_plywood) {
        translate([-explode, 0, 0]) difference() {
            cube([t_plywood, fondo_box, alto_total]);
            translate([t_plywood - rabbet_d, -0.1, alto_total - t_plywood]) cube([rabbet_d+0.1, fondo_box+0.2, t_plywood+0.1]);
            translate([t_plywood - rabbet_d, -0.1, -0.1]) cube([rabbet_d+0.1, fondo_box+0.2, t_plywood+0.1]);
            translate([t_plywood - backer_rab_d, fondo_box - backer_rab_w, -0.1]) cube([backer_rab_d + 0.1, backer_rab_w + 0.1, alto_total + 0.2]);
        }
        translate([ancho_total - t_plywood + explode, 0, 0]) difference() {
            cube([t_plywood, fondo_box, alto_total]);
            translate([-0.1, -0.1, alto_total - t_plywood]) cube([rabbet_d+0.1, fondo_box+0.2, t_plywood+0.1]);
            translate([-0.1, -0.1, -0.1]) cube([rabbet_d+0.1, fondo_box+0.2, t_plywood+0.1]);
            translate([-0.1, fondo_box - backer_rab_w, -0.1]) cube([backer_rab_d + 0.1, backer_rab_w + 0.1, alto_total + 0.2]);
        }
    }

    // B. TOP/BOT
    w_horiz = ancho_total - (2 * (t_plywood - rabbet_d));
    horiz_x = t_plywood - rabbet_d;
    color(color_plywood) {
        translate([horiz_x, 0, -explode]) cube([w_horiz, fondo_box, t_plywood]);
        translate([horiz_x, 0, alto_total - t_plywood + explode]) cube([w_horiz, fondo_box, t_plywood]);
    }

    // C. THE BACKER
    w_backer = ancho_total - (2 * (t_plywood - backer_rab_d));
    translate([t_plywood - backer_rab_d, fondo_box - backer_rab_w + (explode*1.5), t_plywood]) {
        color([0.7, 0.6, 0.4]) cube([w_backer, t_backer, alto_total - (2*t_plywood)]);
    }

    // D. MOUNTING BRACKET (Hanging Rail)
    w_bracket = ancho_total - (2 * t_plywood);
    color(color_maple) {
        translate([t_plywood, fondo_box - backer_rab_w - t_bracket + (explode*2), alto_total - t_plywood - h_bracket]) {
            cube([w_bracket, t_bracket, h_bracket]);
        }
    }

    // E. FACE FRAME
    color(color_maple) translate([0, -t_face_maple - explode, 0]) {
        difference() {
            cube([ancho_total, t_face_maple, alto_total]);
            translate([t_plywood, -0.1, t_plywood]) cube([ancho_total - (2 * t_plywood), t_face_maple+0.2, alto_total - (2 * t_plywood)]);
        }
    }

    // F. DOORS
    gap = (ancho_total - (2 * door_w)) / 3;
    d_exp = explode * 2.5; 
    translate([gap, -(t_face_maple + t_door) - d_exp, (alto_total - door_h)/2]) 
        shaker_door(false);
    translate([ancho_total - gap, -(t_face_maple + t_door) - d_exp, (alto_total - door_h)/2]) 
        shaker_door(true);
}

assembly();
translate([0, 0, alto_total + 0.125]) assembly();

// --- 6. SHOP CUT LIST ---
echo("--- SHOP CUT LIST (PER UNIT) ---");
echo(str("DOOR PANEL (2): ", panel_w_calc, " x ", panel_h_calc));
echo(str("DOOR STILES (4): ", door_h, " x ", frame_w));
echo(str("DOOR RAILS (4): ", door_w - (2 * frame_w), " x ", frame_w));