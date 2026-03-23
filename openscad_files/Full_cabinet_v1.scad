
// --- 1. MASTER SPECS (INCHES) ---
ancho_total = 35.5; 
alto_total  = 38.75;   
fondo_box   = 12.25;    
t_plywood   = 0.75;     
t_faceframe = 0.75;     
rabbet_d    = 0.125; // 1/8" deep internal rabbets

// --- 2. COLORS ---
color_plywood = [0.82, 0.71, 0.55]; 
color_maple   = [0.45, 0.29, 0.07]; 

$fn = 60;

module cabinet_side(is_left) {
    color(color_plywood)
    difference() {
        // Main Plywood Side (Full height)
        cube([t_plywood, fondo_box, alto_total]);

        // INTERNAL RABBETS (1/8" deep)
        // Since it's on the INSIDE, the left side cuts from its right face, 
        // and the right side cuts from its left face.
        x_pos = is_left ? t_plywood - rabbet_d : 0;
        
        // Top Rabbet Cut
        translate([x_pos, -0.1, alto_total - t_plywood]) 
            cube([rabbet_d + 0.1, fondo_box + 0.2, t_plywood + 0.1]);
            
        // Bottom Rabbet Cut
        translate([x_pos, -0.1, -0.1]) 
            cube([rabbet_d + 0.1, fondo_box + 0.2, t_plywood + 0.1]);

        // SHELF PIN HOLES (centered)
        shelf_z = alto_total / 2;
        for (y = [2, fondo_box - 2]) {
            translate([is_left ? t_plywood : 0, y, shelf_z])
            rotate([0, 90, 0])
            cylinder(d=1/4, h=1, center=true);
        }
    }
}

module interior_horizontal() {
    // Width is total width minus the "meat" left on the sides after rabbeting
    // ancho - (2 * (t - rabbet))
    w_horiz = ancho_total - (2 * (t_plywood - rabbet_d));
    
    color(color_plywood)
    cube([w_horiz, fondo_box, t_plywood]);
}

module assembly() {
    // 1. SIDES
    cabinet_side(true);
    translate([ancho_total - t_plywood, 0, 0]) cabinet_side(false);
    
    // 2. TOP & BOTTOM (Nested into the side rabbets)
    horiz_x_start = t_plywood - rabbet_d;
    translate([horiz_x_start, 0, 0]) interior_horizontal(); // Bottom
    translate([horiz_x_start, 0, alto_total - t_plywood]) interior_horizontal(); // Top

    // 3. THE SHELF (Floating on pins)
    s_width = ancho_total - (2 * t_plywood) - 0.0625;
    s_depth = fondo_box - 0.5;
    color(color_plywood)
    translate([(ancho_total - s_width)/2, 0.25, alto_total/2])
        cube([s_width, s_depth, t_plywood]);

    // 4. THE FACE FRAME (Maple)
    color(color_maple)
    translate([0, -t_faceframe, 0])
    difference() {
        cube([ancho_total, t_faceframe, alto_total]);
        // Opening matches the internal space between sides
        translate([t_plywood, -0.1, t_plywood])
            cube([ancho_total - (2 * t_plywood), t_faceframe + 0.2, alto_total - (2 * t_plywood)]);
    }
}

// Render stacked units
assembly();
translate([0, 0, alto_total + 0.125]) assembly();