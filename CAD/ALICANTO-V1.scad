include <BOSL/constants.scad>
use <BOSL/shapes.scad>
use <BOSL/masks.scad>
use <BOSL/transforms.scad>
include <JointSCAD/JointSCAD.scad>

DrawRing=false;
CutNotches=true;
DrawFin=false;
DrawNoseconeBulkhead=false;
DrawAvbayBulkhead=false;
DrawAvbaySled = false;
DrawAftFairing = false;
DrawRingMarkingGuide=false;
DrawRingDrillingJig=false;
DrawDrillingJigTop = true;
DrawDrillingJigBottom = true;
DrawInner=false;
DrawGluingJig=false;

// Lowes birch plywood
//PlywoodThickness=5.1;

// Woodcraft Baltic birch plywood 5-ply, measures 5.8mm Dec 2024
PlywoodThickness=5.8;
CenteringRingThickness = PlywoodThickness * 2;
FinThickness = PlywoodThickness;

// Measured, 98mm Blue Tube, Nov 2024
BodyID=98.5;
MountOD=57.3;
NoseconeOD=98;
NoseconeID=93;
BodyOD98mm=101.0;

$fn=256;
bool_allowance=0.01;
fillet_radius=0;
InMm=25.4;
M3ScrewHoleDiameter = 3.5;
M3InsetHoleDiameter = 4;
M3InsetHoleDepth = 6;
// Measured 0.175
LaserKerf=0.175;


// General measurements
ThreadedRod_diameter=(0.25*InMm)+1;
UboltHoleDiameter=0.25*InMm+1;

// Centering ring measurements
RingZ=CenteringRingThickness;
FinZ=FinThickness;
HoleZ=CenteringRingThickness;
RingWidth=(BodyID-MountOD)/2;
NotchWidth=FinZ;
NotchLength=RingWidth/2;
RingNotchBase=MountOD/2+NotchLength;
FinNotches=[0,90,180,270];

// Fin measurements
FinRootChord=12*InMm;
FinTipChord=6*InMm;
FinHeight=5*InMm;
FinSweep=4.5*InMm;
FinTabLength=12*InMm;
FinTabHeight=0.875*InMm;
MiddleCenteringRingX=1*InMm;
FinOutline=[[0,0],
            [FinSweep,FinHeight],
            [FinSweep+FinTipChord,FinHeight],
            [FinRootChord,0],
            [FinRootChord,-NotchLength],
            [FinRootChord-CenteringRingThickness,-NotchLength],
            [FinRootChord-CenteringRingThickness,-RingWidth],
            [MiddleCenteringRingX+CenteringRingThickness,-RingWidth],
            [MiddleCenteringRingX+CenteringRingThickness,-NotchLength],
            [MiddleCenteringRingX,-NotchLength],
            [MiddleCenteringRingX,-RingWidth],
            [0,-(NotchLength*2)]];

// Ring Marking Guide measurements
RingMarkingGuideAngles=[45,135,225,315];

// Ring drilling jig measurements
DrillingX = (7 * InMm);
DrillingY = (6 * InMm);
DrillingZ = BodyID + 10;
DrillingJigBodyThickness = 10;
RingDrillingJigScale = (1+(1/BodyID));
MortiseDimensions = [1,1,1];
MortiseProportions = [0.8,0.2,0.8];

// Fairing measurements
ScrewHoleDiameter = (7/32) * InMm;
FairingFinNotchWidth = FinThickness + 1;
FairingAftThickness = 3;
FairingAftID = BodyOD98mm + 1.5;
FairingAftOD = FairingAftID + (FairingAftThickness*2);
FairingAftNotchInset = 1.5 * InMm;
FairingAftScrewInset = FairingAftNotchInset + (0.25 * InMm);
FairingAftLength = FairingAftScrewInset + (1 * InMm);

module joiner(neck, shoulder, depth, height, scale=1.2) {

    leftOut = [- neck / 2, 0];
    rightOut = [neck / 2, 0];
    leftIn = [- shoulder / 2, depth];
    rightIn = [shoulder / 2, depth];
    linear_extrude(height = height, scale = scale)
        polygon(points = [leftOut, rightOut, rightIn, leftIn]);
}

module CenteringRing(notches,CutCenterHole) {
    difference() {
        // Ring
        cyl(h=RingZ,d=BodyID);
        // Motor mount hole
        if(CutCenterHole) cyl(h=HoleZ,d=MountOD);
        if(notches) {
            for(i=FinNotches) rotate(i) 
                translate([RingNotchBase,0,0])
                    cuboid([NotchLength,NotchWidth,RingZ],align=V_RIGHT);
        }
    }
}

module Fin() {
    // Fin
        linear_extrude(height=FinThickness) polygon(FinOutline);
}

module RingMarkingGuide() {
    GuideWallThickness=2;
    // 3D-printed guide for marking fastener holes
    difference() {
        // Base
        cyl(h=(RingZ+GuideWallThickness),d=(BodyID+(GuideWallThickness*2)),align=V_TOP);
        // Wall
        translate([0,0,GuideWallThickness]) cyl(h=(RingZ+GuideWallThickness),d=(BodyID+(GuideWallThickness/2)),align=V_TOP);
        // Center hole
        cyl(h=RingZ,d=(MountOD*1.1),align=V_TOP);
        // Fin notches (for reference)
        for(i=FinNotches) rotate(i) 
            translate([RingNotchBase,0,0])
                cuboid([NotchLength,NotchWidth,RingZ],align=V_RIGHT);
        // Body tube notches (for reference)
        for(i=RingMarkingGuideAngles) rotate(i) 
            translate([(BodyID/2),0,(RingZ+GuideWallThickness)]) 
                rotate([45,0,0]) 
                cuboid([(GuideWallThickness*2),2,2]);
        // Motor mount notches (for reference)
        for(i=RingMarkingGuideAngles) rotate([0,0,i]) 
            translate([((MountOD+RingWidth)*0.4),0,0])
                rotate([45,90,0]) 
                cuboid([(GuideWallThickness*2),2,2]);
        // Screw holes
        for(i=RingMarkingGuideAngles) rotate(i) 
            translate([(BodyID/2),0,((RingZ+GuideWallThickness)/2)])
                xcyl(d=2,h=(GuideWallThickness*2),align=V_TOP);
        // Dowel nut holes
        for(i=RingMarkingGuideAngles) rotate([0,0,i]) 
            translate([((MountOD+RingWidth)/2),0,0])
                rotate([0,90,0]) 
                xcyl(d=2,h=(GuideWallThickness*2));
    }
}

module DrillingJig() {
    difference() {
        cuboid([DrillingX,DrillingY,DrillingZ],align=V_TOP);
        translate([0,0,(DrillingZ-(BodyID/2))]) 
            cuboid([BodyID,(RingZ+1.5),BodyID],align=V_TOP);
        translate([0,0,((DrillingZ/2)+((DrillingZ-BodyID)/2))]) 
            rotate([90,0,0]) 
               cyl(h=(RingZ+1.5),d=BodyID);
        for(i=[-1,1]) {
            translate([0,(((RingZ/2)+(DrillingY/2)+1.5)*i),-DrillingJigBodyThickness]) 
                cuboid([DrillingX,DrillingY,DrillingZ],align=V_TOP);
        }
        cyl(h=(DrillingZ*2),d=((3/8)*InMm));
    }
}

module ChargeWell() {
    difference() {
        union() {
            cyl(h=ChargeWellDepth,d=ChargeWellDiameter,align=V_TOP);
            cyl(h=(fillet_radius*2),d=(ChargeWellDiameter+(fillet_radius*4)),align=V_TOP);
        }
        // Fillet base to bulkhead
        torus(id=(ChargeWellDiameter),od=(ChargeWellDiameter+(fillet_radius*8)),align=V_TOP);
        // Hollow out well
        translate([0,0,ChargeWellWall]) 
            cyl(h=ChargeWellDepth,d=(ChargeWellDiameter-(ChargeWellWall*2)),align=V_TOP);
//        // Drill mounting hole (not needed, printed with bulkhead)
//        cyl(h=ChargeWellDepth,d=M3ScrewHoleDiameter,align=V_TOP);
    }
}

module Fairing(FHeight,FDiamMin,FDiamMax,FHoleDiam) {
    difference() {
        // Ring
        cyl(h=FHeight, d1=FDiamMin, d2=FDiamMax, fillet=fillet_radius ,align=V_TOP);
        cyl(h=FHeight, d=BodyOD98mm,align=V_TOP);
        // Holes
        translate([0,0,(FairingFlangeLength-FairingFlangeScrewSetback)]) {
            for(i = [0,90]) {
                rotate([0,0,i])xcyl(h=FDiamMax, d=FHoleDiam);
            }
        }
        // Notch
        for(i=[45,135]) {
            rotate([0,0,i]) 
                cuboid([FairingFinNotchWidth,(BodyOD98mm*2),FairingFlangeLength],align=V_TOP);
        }
    }
}


// ********
// Main
// ********
offset(delta=LaserKerf/2) {
    projection() {
        if(DrawRing) {
            CenteringRing(CutNotches,true);
        }
        if(DrawFin) {
            Fin();
        }
    }
}

if(DrawNoseconeBulkhead) {
    offset(delta=LaserKerf/2) {
        projection() {
            difference() {
                if(DrawInner) {
                    cyl(h=PlywoodThickness,d=NoseconeID);
                } else {
                    cyl(h=PlywoodThickness,d=NoseconeOD);
                }
                cyl(h=PlywoodThickness,d=ThreadedRod_diameter);
            }
        }
    }
}

// Avbay measurements
AvbayOD=98;
FudgeID=1;
AvbayID=AvbayOD-(1.84*2)+FudgeID;
AvbayBulkheadThickness=0.25*InMm;
UboltCenterToCenter=1.375*InMm;
ThreadedRodCenterToCenter=2.5*InMm;
ChargeWellDiameter = 0.85 * InMm;
ChargeWellWall = 2;
ChargeWellDepth = 15;
ChargeWellCoordinates = [[-45,(AvbayOD/3)],[45,(AvbayOD/3)]];
ChargeWireDiameter = 3;

if(DrawAvbayBulkhead) {
    difference() {
        // Bulkhead
        union() {
            translate([0,0,(AvbayBulkheadThickness/2)]) 
                cyl(h=(AvbayBulkheadThickness/2),d=AvbayOD,align=V_TOP);
            cyl(h=AvbayBulkheadThickness,d=AvbayID,align=V_TOP);
            // Charge wells
        }
        // U-bolt holes
        for(i=[1,-1]) {
            translate([((UboltCenterToCenter/2)*i),0,0]) 
                cyl(h=AvbayBulkheadThickness,d=UboltHoleDiameter,align=V_TOP);
        }
        // Threaded rod holes
        for(i=[1,-1]) {
            translate([0,((ThreadedRodCenterToCenter/2)*i),0]) 
                cyl(h=AvbayBulkheadThickness,d=UboltHoleDiameter,align=V_TOP);
        }
        // Charge well wire holes
        for(i=ChargeWellCoordinates) {
            rotate([0,0,(i[0]-90)]) 
                translate([i[1],0,0]) 
                    cyl(h=AvbayBulkheadThickness,d=ChargeWireDiameter,align=V_TOP);
        }
    }
    for(i=ChargeWellCoordinates) {
        translate([0,0,AvbayBulkheadThickness]) 
            rotate([0,0,i[0]]) 
                translate([0,i[1],0]) 
                    ChargeWell();
    }
}

if(DrawAvbaySled) {
    // Avionics sled
}

if(DrawAftFairing) {
    // Fairing to retain body tube between fin slots
    difference() {
        // Base
        cyl(h=FairingAftLength,d=FairingAftOD,align=V_TOP);
        // Custom chamfer
        up(FairingAftLength) chamfer_cylinder_mask(r=(FairingAftOD/2),chamfer=3,ang=35);
        // Cut interior
#        cyl(h=FairingAftLength,d=FairingAftID,align=V_TOP);
        // Notches and holes
        for(i=FinNotches) {
            // Fin notches
            rotate(i) 
                translate([0,0,FairingAftNotchInset])
                    cuboid([FairingAftOD,FairingFinNotchWidth,FairingAftLength],align=(V_TOP+V_LEFT));
            // Screw holes
            rotate(i+45) 
                translate([0,0,FairingAftScrewInset])
                    xcyl(d=ScrewHoleDiameter,h=FairingAftOD,align=V_LEFT);
        }
    }
}

if(DrawRingMarkingGuide) {
    RingMarkingGuide();
}

if(DrawRingDrillingJig) {
    if(DrawDrillingJigTop) {
        difference() {
            DrillingJig();
            translate([0,0,-DrillingJigBodyThickness]) 
                cuboid([DrillingX,DrillingY,DrillingZ],align=V_TOP);
//            mortise(MortiseDimensions,MortiseProportions);
        }
    }
    if(DrawDrillingJigBottom) {
        difference() {
            DrillingJig();
            translate([0,0,(DrillingZ-DrillingJigBodyThickness)]) 
                cuboid([DrillingX,DrillingY,DrillingZ],align=V_TOP);
        }
    }
}

if(DrawGluingJig) {
    difference() {
        union() {
            cyl(d=MountOD,h=(RingZ*2.5),fillet=fillet_radius,align=V_TOP);
            cyl(d=(BodyOD98mm*1.5),h=RingZ,fillet=fillet_radius,align=V_TOP);
            for(i=[0,90,180,270]) {
                rotate([0,0,i]) 
                    translate([(BodyOD98mm*0.6),0,0]) 
                        cuboid([(BodyOD98mm*0.6),(FinThickness*3),(RingZ*8)],fillet=fillet_radius,align=V_TOP+V_RIGHT);
            }
        }
        for(i=[0,90,180,270]) {
            rotate([0,0,i]) 
                translate([(BodyOD98mm*0.6),0,RingZ]) 
                    cuboid([(BodyOD98mm*0.5),FinThickness,(RingZ*8)],align=V_TOP+V_RIGHT);
        }
    }
}
