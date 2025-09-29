DrawInner = false;

LaserKerf=0.175;

offset(delta=LaserKerf/2) {
    if(DrawInner) {
        projection() {
            import("../BulkheadInner-Body.stl");
        }
} else {
        projection() {
            import("../BulkheadOuter-Body.stl");
        }
    }
}
