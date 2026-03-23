import FreeCAD as App
import Part
import Draft
import FreeCADGui as Gui

# 1. SETUP DOCUMENT
doc = App.activeDocument() if App.activeDocument() else App.newDocument("Cabinet_Build")

# 2. EXACT SPECS (INCHES)
W = 35.5
H = 38.75
D = 12.25
t = 0.75      # Plywood
mT = 0.75     # Maple Face Frame
r = 0.125     # Internal Rabbet Depth
backer_t = 0.25

# Door Specs
dw = 17.5625  # 17-9/16"
dh = 38.625   # 38-5/8"
dt = 0.75

# 3. COLOR DEFINITIONS
ply_col = (0.82, 0.71, 0.55)
maple_col = (0.45, 0.29, 0.07)

def create_cabinet(z_offset, name_suffix):
    # A. SIDES (Full height)
    s_l = doc.addObject("Part::Box", f"Side_L_{name_suffix}")
    s_l.Length, s_l.Width, s_l.Height = t, D, H
    s_l.Placement.Base = App.Vector(0, 0, z_offset)
    s_l.ViewObject.ShapeColor = ply_col

    s_r = doc.addObject("Part::Box", f"Side_R_{name_suffix}")
    s_r.Length, s_r.Width, s_r.Height = t, D, H
    s_r.Placement.Base = App.Vector(W - t, 0, z_offset)
    s_r.ViewObject.ShapeColor = ply_col

    # B. TOP & BOTTOM (Nested into 1/8" rabbets)
    horiz_w = W - (2 * (t - r))
    horiz_x = t - r
    
    bot = doc.addObject("Part::Box", f"Bottom_{name_suffix}")
    bot.Length, bot.Width, bot.Height = horiz_w, D, t
    bot.Placement.Base = App.Vector(horiz_x, 0, z_offset)
    bot.ViewObject.ShapeColor = ply_col

    top = doc.addObject("Part::Box", f"Top_{name_suffix}")
    top.Length, top.Width, top.Height = horiz_w, D, t
    top.Placement.Base = App.Vector(horiz_x, 0, z_offset + H - t)
    top.ViewObject.ShapeColor = ply_col

    # C. FACE FRAME (Maple)
    # Simplified as a solid border for the script
    frame = doc.addObject("Part::Box", f"FaceFrame_{name_suffix}")
    frame.Length, frame.Width, frame.Height = W, mT, H
    frame.Placement.Base = App.Vector(0, -mT, z_offset)
    frame.ViewObject.ShapeColor = maple_col
    frame.ViewObject.Transparency = 50 # See the box inside

    # D. DOORS
    gap = (W - (2 * dw)) / 3
    d_l = doc.addObject("Part::Box", f"Door_L_{name_suffix}")
    d_l.Length, d_l.Width, d_l.Height = dw, dt, dh
    d_l.Placement.Base = App.Vector(gap, -(mT + dt + 0.1), z_offset + (H - dh)/2)
    
    d_r = doc.addObject("Part::Box", f"Door_R_{name_suffix}")
    d_r.Length, d_r.Width, d_r.Height = dw, dt, dh
    d_r.Placement.Base = App.Vector(W - gap - dw, -(mT + dt + 0.1), z_offset + (H - dh)/2)

# --- GENERATE STACK ---
create_cabinet(0, "Lower")
create_cabinet(H + 0.125, "Upper") # 1/8" gap between units

doc.recompute()
Gui.SendMsgToActiveView("ViewFit")