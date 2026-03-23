// --- PARÁMETROS EN PULGADAS ---
ancho = 35 + 1/2; 
alto  = 38 + 3/4;   // Alto de un solo gabinete
fondo = 20;         // Ajusta esto a tu medida en pulgadas (ej. 20 o 24)
t     = 3/4;        // Grosor de la madera (Triplay/Plywood)

// Factor de suavidad para cilindros (si añades tornillos o agujeros luego)
$fn = 50;

module gabinete_individual() {
    color("linen") {
        // Suelo
        cube([ancho, fondo, t]);
        
        // Techo
        translate([0, 0, alto - t]) 
            cube([ancho, fondo, t]);
        
        // Lateral Izquierdo (va entre el suelo y el techo)
        translate([0, 0, t]) 
            cube([t, fondo, alto - (2 * t)]);
        
        // Lateral Derecho
        translate([ancho - t, 0, t]) 
            cube([t, fondo, alto - (2 * t)]);
        
        // Fondo / Trasera (embutida 1/4 pulgada para que no se vea de lado)
        translate([t, fondo - 1/4, t]) 
            color("gray") 
            cube([ancho - (2 * t), 1/4, alto - (2 * t)]);
    }
}

// --- ENSAMBLE FINAL ---

// Gabinete de ABAJO
gabinete_individual();

// Gabinete de ARRIBA
translate([0, 0, alto]) 
    gabinete_individual();

// --- REFERENCIA DE LA PARED (en pulgadas) ---
// Convertimos los 2400mm a unas 94 pulgadas aprox.
%union() {
    cube([100, 0.5, 94]); // Pared fondo
    cube([0.5, 100, 94]); // Pared lateral
}


// Doors
Door_Frame_W = 2.5;  // Width of the Shaker frame (stiles/rails)
Door_Panel_Inset = 0.25; // How deep the center panel is recessed
Door_Gap = 0.125;    // Gap between the two doors
Door_Open_Angle = 0; // Set to 90 to see them open!


module shaker_door(dw, dh) {
    color("white") union() {
        difference() {
            // The main door slab
            cube([dw, 0.75, dh]); 
            
            // The recessed middle part
            translate([Door_Frame_W, -0.1, Door_Frame_W])
                cube([dw - (Door_Frame_W * 2), Door_Panel_Inset + 0.1, dh - (Door_Frame_W * 2)]);
        }
    }
}

module cabinet(h) {
    // ... (keep your previous box code here) ...

    door_w = (Unit_Width / 2) - (Door_Gap * 1.5);
    door_h = h - (Door_Gap * 2);

    // LEFT DOOR
    translate([Door_Gap, -0.75, Door_Gap])
    rotate([0, 0, -Door_Open_Angle]) // Hinged on the left
        shaker_door(door_w, door_h);

    // RIGHT DOOR
    translate([Unit_Width - Door_Gap, -0.75, Door_Gap])
    rotate([0, 0, Door_Open_Angle]) 
    translate([-door_w, 0, 0])      // Hinged on the right
        shaker_door(door_w, door_h);
}