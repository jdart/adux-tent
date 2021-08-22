tent_angle=10;
tent_rotate=[0, tent_angle, 0];
offset_x=-35;
bottom_padding=0;
pcb_depth=6;
slop=0.9;
caseRounding=2;
casePadding=5;

main();

module caseOutline() {
    hull() {
        offset(casePadding)
        pcb2D();
    }
}

module caseOutlineMinOffset() {
    hull() {
        offset(casePadding-caseRounding)
        pcb2D();
    }
}

module pcb3D() {
    translate([0, 0, -pcb_depth+0.1])
        linear_extrude(height=pcb_depth, center=false, convexity=10)
        pcb2D();
}

module pcb2D() {
    translate([offset_x, 0, 0])
        rotate([0, 180, -5])
        offset(r=slop)
        import(file = "panel.dxf", $fn=100, convexity=10);
}

module main() {
    difference() {
        // primary tent shape
        union() {
            // bottom padding
            translate([0, 0, -bottom_padding]) 
                linear_extrude(bottom_padding)
                projection(cut = false)
                linear_extrude(height=0.1, center=false, convexity=10)
                rotate(a=tent_rotate)
                caseOutline();
                
            minkowski() {               
                // top wedge
                difference() {        
                    linear_extrude(100)
                        projection(cut = false)
                        rotate(a=tent_rotate)
                        linear_extrude(height=0.1, center=false, convexity=10)
                        caseOutlineMinOffset();
                        
                    // cut out wedge on angle
                    rotate(a=tent_rotate)
                        translate([-250, -80, -caseRounding])
                        cube([250, 350, 100]);
                }
                sphere(caseRounding);
            }
        }

        // pcb inset cutout
        translate([0, 0, 0])
            rotate(a=tent_rotate)
            pcb3D();

        // inner hole
        difference() {
            translate([0, 0, -10])
                linear_extrude(height=50, center=false, convexity=10)
                projection(cut = false)
                linear_extrude(height=0.1, center=false, convexity=10)
                rotate(a=tent_rotate)
                offset(-6)
                pcb2D();
            // extra strength for outter edge
            rotate([0, 0, -20])
                translate([-21+offset_x, -22, -pcb_depth-bottom_padding]) 
                cube([20, 48, 30]);
        } 

        // battery/mcu cutout 
        translate([-138+offset_x, 10, -10])
            cube([40, 80, 90]);

        // bottom text
        translate([-50, -10, -bottom_padding-1.6])
            rotate([180, 0, 90])
            linear_extrude(1)
            text(str(tent_angle, "°"));
    }
}
