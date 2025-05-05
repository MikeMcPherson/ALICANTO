LaserKerf=0.175;
offset(delta=LaserKerf/2) {
    projection() {
        import("CenteringRing-Body.stl");
    }
}
