// --- 1. YOUR EXACT SPECS (INCHES) ---
ancho_total   = 35.5; 
alto_total    = 38.75;   
fondo_box     = 12.25;    // Plywood depth
t_plywood     = 0.75;     // 3/4" Plywood
t_backer      = 0.25;     // 1/4" Backer panel
t_face_maple  = 0.75;     // 3/4" Thick Face Frame
rabbet_d      = 0.125;    // 1/8" Deep internal rabbets

// --- 2. COLORS & VISUALS ---
color_plywood = [0.82, 0.71, 0.55]; // Light Brown
color_maple   = [0.45, 0.29, 0.07]; // Dark Brown
Show_Labels   = true;
$fn = 60;

// --- 3. THE PARTS ---

module cabinet_side(is_left) {
    color(color_plywood)
    difference() {
        // The main side panel
        cube([t_plywood, fondo_box, alto_total]);
        
        // Internal Rabbets for Top & Bottom
        x_pos = is_left ? t_plywood - rabbet_d : -0.1;
        
        // Top Rabbet
        translate([x_pos, -0.1, alto_total - t_plywood]) 
            cube([rabbet_d + 0.1, fondo_box + 0.2, t_plywood + 0.1]);
            
        // Bottom Rabbet
        translate([x_pos, -0.1, -0.1]) 
            cube([rabbet_d + 0.1, fondo_box + 0.2, t_plywood + 0.1]);

        // Shelf Pin Holes (Centered)
        shelf_z = alto_total / 2;
        for (y = [2, fondo_box - 2]) {
            translate([is_left ? t_plywood : 0, y, shelf_z])
            rotate([0, 90, 0]) cylinder(d=1/4, h=1, center=true);
        }
    }
}

module assembly() {
    // A. THE SIDES (Plywood)
    cabinet_side(true);
    translate([ancho_total - t_plywood, 0, 0]) cabinet_side(false);
    
    // B. TOP & BOTTOM (Nested into 1/8" rabbets)
    // Width = Total - (Side Thickness * 2) + (Rabbet Depth * 2)
    w_horiz = ancho_total - (2 * (t_plywood - rabbet_d));
    horiz_x = t_plywood - rabbet_d;
    color(color_plywood) {
        translate([horiz_x, 0, 0]) cube([w_horiz, fondo_box, t_plywood]);
        translate([horiz_x, 0, alto_total - t_plywood]) cube([w_horiz, fondo_box, t_plywood]);
    }

    // C. THE BACKER (1/4" Plywood)
    translate([t_plywood, fondo_box - t_backer, t_plywood])
        color([0.7, 0.6, 0.4]) // Slightly darker ply for backer
        cube([ancho_total - (2 * t_plywood), t_backer, alto_total - (2 * t_plywood)]);

    // D. THE FACE FRAME (3/4" Dark Maple)
    color(color_maple)
    translate([0, -t_face_maple, 0])
    difference() {
        cube([ancho_total, t_face_maple, alto_total]);
        // Opening for the cabinet interior
        translate([t_plywood, -0.1, t_plywood])
            cube([ancho_total - (2 * t_plywood), t_face_maple + 0.2, alto_total - (2 * t_plywood)]);
    }

    // E. THE LABELS
    if (Show_Labels) {
        // Overall Width
        translate([ancho_total/2, -3, alto_total + 2]) rotate([90,0,0]) 
            color("black") text(str(ancho_total, "\" W"), size=1.8, halign="center");
        // Overall Height
        translate([ancho_total + 3, fondo_box/2, alto_total/2]) rotate([90,0,90]) 
            color("black") text(str(alto_total, "\" H"), size=1.8, halign="center");
        // Depth
        translate([ancho_total/2, fondo_box + 2, 0]) rotate([90,0,180]) 
            color("black") text(str(fondo_box, "\" DEPTH"), size=1.8, halign="center");
    }
}

// --- FINAL RENDER ---
assembly();
translate([0, 0, alto_total + 0.125]) assembly(); // 1/8" gap between units