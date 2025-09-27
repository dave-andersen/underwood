// --- Parameters ---
// All dimensions are in millimeters (mm)

// Main Body Dimensions
top_width = 18;      // 2cm across the narrow way
top_length = 24;     // 3cm long
bottom_width = 26;   // 3cm across the narrow way
bottom_length = 34;  // 4cm long
foot_height = 14;    // 1.5cm tall

// Screw Hole Dimensions
screw_hole_dia = 7;  // ID of screw hole

// Counterbore (Wider opening at the bottom for a screw head)
counterbore_height = foot_height - 7.5;
counterbore_dia = 14; // Assumed diameter based on image proportions. Change if needed.

// Press-fit Cylinder on Top Face
cylinder_height_1 = 2;     // First segment: constant 11.5mm diameter
cylinder_height_2 = 1.0;     // Second segment: expand to 12.5mm diameter
cylinder_height_3 = 2.0;     // Third segment: shrink to 10.5mm diameter
total_cylinder_height = cylinder_height_1 + cylinder_height_2 + cylinder_height_3;

cylinder_dia_1 = 11.25;       // Starting diameter
cylinder_dia_2 = 12.1;       // Expanded diameter (11.5 + 1.0)
cylinder_dia_3 = 10.5;       // Final diameter (12.5 - 2.0)

cylinder_inner_dia = screw_hole_dia; // Interior diameter equals hole diameter


// --- Module Definition ---
module typewriter_foot() {
    // Use difference() to create the main body and then subtract the holes
    difference() {
        // Combine the main body and press-fit cylinder
        union() {
            // 1. Main trapezoidal body using polyhedron for precision
            polyhedron(
            points = [
                // Bottom vertices (z=0)
                [-bottom_width/2, -bottom_length/2, 0], // 0: front-left
                [ bottom_width/2, -bottom_length/2, 0], // 1: front-right
                [ bottom_width/2,  bottom_length/2, 0], // 2: back-right
                [-bottom_width/2,  bottom_length/2, 0], // 3: back-left
                // Top vertices (z=foot_height)
                [-top_width/2, -top_length/2, foot_height],    // 4: front-left
                [ top_width/2, -top_length/2, foot_height],    // 5: front-right
                [ top_width/2,  top_length/2, foot_height],    // 6: back-right
                [-top_width/2,  top_length/2, foot_height]     // 7: back-left
            ],
            // Define the 6 faces of the shape using the vertex indices above
            faces = [
                [0, 1, 2, 3], // Bottom face
                [4, 5, 1, 0], // Front face
                [7, 6, 5, 4], // Top face
                [5, 6, 2, 1], // Right face
                [6, 7, 3, 2], // Back face
                [7, 4, 0, 3]  // Left face
            ]
        );

        // 2. Press-fit cylinder on top face with locking profile
        translate([0, 0, foot_height]) {
            difference() {
                // Outer cylinder with press-fit profile
                union() {
                    // Segment 1: Constant 11.5mm diameter for 1.5mm height
                    cylinder(h = cylinder_height_1, d = cylinder_dia_1, center = false, $fn=64);

                    // Segment 2: Expand from 11.5mm to 12.5mm over 1mm height
                    translate([0, 0, cylinder_height_1]) {
                        cylinder(h = cylinder_height_2, d1 = cylinder_dia_1, d2 = cylinder_dia_2, center = false, $fn=64);
                    }

                    // Segment 3: Shrink from 12.5mm to 10.5mm over 2mm height
                    translate([0, 0, cylinder_height_1 + cylinder_height_2]) {
                        cylinder(h = cylinder_height_3, d1 = cylinder_dia_2, d2 = cylinder_dia_3, center = false, $fn=64);
                    }
                }
                // Inner hole
                translate([0, 0, -0.1]) {
                    cylinder(h = total_cylinder_height + 0.2, d = cylinder_inner_dia, center = false, $fn=64);
                }
            }
        }
        }

        // 3. Center screw hole (goes all the way through)
        // We make it slightly taller than the object to ensure a clean cut
        translate([0, 0, -1]) {
            cylinder(h = foot_height + total_cylinder_height + 2, d = screw_hole_dia, center = false, $fn=64);
        }

        // 4. Counterbore (the wider recess at the bottom)
        // Also made slightly taller to ensure a clean cut from the bottom
         translate([0, 0, -1]) {
            cylinder(h = counterbore_height + 1, d = counterbore_dia, center = false, $fn=64);
        }
    }
}


// --- Render the Final Object ---
typewriter_foot();