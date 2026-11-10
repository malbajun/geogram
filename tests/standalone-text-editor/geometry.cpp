#include <geogram/basic/common.h>
#include <geogram/delaunay/delaunay.h>
#include <geogram/NL/nl.h>
#include <iostream>

int main() {
    GEO::initialize(GEO::GEOGRAM_INSTALL_NONE);
    NLContext context = nlNewContext();
    if(context == nullptr) { return 1; }
    nlDeleteContext(context);

    const double tetrahedron[] = {0,0,0, 1,0,0, 0,1,0, 0,0,1};
    GEO::Delaunay_var tetgen = GEO::Delaunay::create(3, "tetgen");
    if(tetgen.is_null()) { return 2; }
    tetgen->set_vertices(4, tetrahedron);
    if(tetgen->nb_cells() != 1) { return 3; }

    const double triangle[] = {0,0, 1,0, 0,1};
    GEO::Delaunay_var triangulation = GEO::Delaunay::create(2, "triangle");
    if(triangulation.is_null()) { return 4; }
    triangulation->set_vertices(3, triangle);
    if(triangulation->nb_cells() != 1) { return 5; }
    std::cout << "OpenNL, TetGen and Triangle checks passed\n";
}
