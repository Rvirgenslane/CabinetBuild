// --- 1. MASTER SPECS (INCHES) ---
ancho_total = 35.5; 
alto_total  = 38.75;   
fondo_box   = 12.25;    
t_plywood   = 0.75;     
t_faceframe = 0.75;     
rabbet_d    = 0.125; 

// --- 2. TOGGLES & COLORS ---
Show_Labels = true; // Set to false to hide text
color_plywood = [0.82, 0.71, 0.55]; 
color_maple   = [0.45, 0.29, 0.07]; 

$fn = 60;

// --- 3. LABEL HELPER MODULE ---
module dim_label(txt, s=1.5) {
    if (Show_Labels) {
        color("black")
        linear_extrude(0.1)
            text(txt, size=s, halign="center", valign="center", font="Arial:style=Bold");
    }
}

// --- 4. COMPONENT MODULES ---
module cabinet_side(is_left) {
    color(color_plywood)
    difference() {
        cube([t_plywood, fondo_box, alto_total]);
        
        // Internal Rabbets
        x_pos = is_left ? t_plywood - rabbet_d : 0;
        translate([x_pos, -0.1, alto_total - t_plywood]) cube([rabbet_d+0.1, fondo_box+0.2, t_plywood+0.1]);
        translate([x_pos, -0.1, -0.1]) cube([rabbet_d+0.1, fondo_box+0.2, t_plywood+0.1]);

        // Shelf Pin Holes
        shelf_z = alto_total / 2;
        for (y = [2, fondo_box - 2]) {
            translate([is_left ? t_plywood : 0, y, shelf_z])
            rotate([0, 90, 0]) cylinder(d=1/4, h=1, center=true);
        }
    }
}

module assembly() {
    // SIDES
    cabinet_side(true);
    translate([ancho_total - t_plywood, 0, 0]) cabinet_side(false);
    
    // TOP & BOTTOM (Sized for internal rabbets)
    w_horiz = ancho_total - (2 * (t_plywood - rabbet_d));
    horiz_x = t_plywood - rabbet_d;
    color(color_plywood) {
        translate([horiz_x, 0, 0]) cube([w_horiz, fondo_box, t_plywood]);
        translate([horiz_x, 0, alto_total - t_plywood]) cube([w_horiz, fondo_box, t_plywood]);
    }

    // SHELF
    color(color_plywood)
    translate([(ancho_total - (ancho_total-1.5))/2, 0.25, alto_total/2])
        cube([ancho_total - 1.56, fondo_box - 0.5, t_plywood]);

    // FACE FRAME
    color(color_maple)
    translate([0, -t_faceframe, 0])
    difference() {
        cube([ancho_total, t_faceframe, alto_total]);
        translate([t_plywood, -0.1, t_plywood])
            cube([ancho_total - (2 * t_plywood), t_faceframe + 0.2, alto_total - (2 * t_plywood)]);
    }

    // --- MEASUREMENT LABELS ---
    // Width Label
    translate([ancho_total/2, -2, alto_total + 2])
        rotate([90, 0, 0]) dim_label(str(ancho_total, "\" WIDTH"));

    // Height Label
    translate([ancho_total + 2, fondo_box/2, alto_total/2])
        rotate([90, 0, 90]) dim_label(str(alto_total, "\" HEIGHT"));
        
    // Depth Label
    translate([ancho_total/2, fondo_box + 2, 0])
        rotate([90, 0, 180]) dim_label(str(fondo_box, "\" DEPTH"));
}

// --- FINAL RENDER ---
assembly();
translate([0, 0, alto_total + 0.125]) assembly();