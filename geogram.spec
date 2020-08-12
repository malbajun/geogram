%define        oname Geogram

Name:          geogram
Version:       1.7.5
Release:       alt1
Summary:       Git mirror of the geogram library by INRIA
License:       Unlicensed
Group:         Sciences/Mathematics
Url:           http://alice.loria.fr/index.php/software/4-library/75-geogram.html
Vcs:           https://github.com/alicevision/geogram.git
Source:        %name-%version.tar
Packager:      Pavel Skrylev <majioa@altlinux.org>

BuildRequires(pre): rpm-macros-cmake
#BuildRequires(pre): rpm-build-python3
BuildRequires: cmake
#BuildRequires: eigen3
BuildRequires: gcc-c++
#BuildRequires: boost-devel
#BuildRequires: boost-program_options-devel
#BuildRequires: boost-python-devel
#BuildRequires: ilmbase-devel

Requires:      lib%{name} = %EVR

%description
Geogram is a programming library of geometric algorithms. It includes a simple
yet efficient Mesh data structure (for surfacic and volumetric meshes), exact
computer arithmetics (a-la Shewchuck, implemented in GEO::expansion ), a
predicate code generator (PCK : Predicate Construction Kit), standard geometric
predicates (orient/insphere), Delaunay triangulation, Voronoi diagram, spatial
search data structures, spatial sorting) and less standard ones (more general
geometric predicates, intersection between a Voronoi diagram and a triangular
or tetrahedral mesh embedded in n dimensions). The latter is used by
FWD/WarpDrive, the first algorithm that computes semi-discrete Optimal
Transport in 3d that scales up to 1 million Dirac masses.


%package       -n lib%{name}
Group:         System/Libraries
Summary:       Library code for %name

%description   -n lib%{name}
%summary.


%package       -n lib%{name}-devel
Group:         Development/C++
Summary:       Development files for %name

Requires:      lib%{name} = %EVR

%description   -n lib%{name}-devel
%summary.


%prep
%setup

%build
%cmake #-DALEMBIC_LIB_USES_BOOST:BOOT=ON \
#       -DUSE_PYALEMBIC:BOOL=ON
%cmake_build

%install
%cmakeinstall_std


%files
%doc README*
#%_bindir/*

%files         -n lib%{name}
%doc README*
#%_libdir/lib%{oname}*.so
#%_libdir/lib%{oname}*.so.*

%files         -n lib%{name}-devel
#%_includedir/%{oname}
#%_libdir/cmake/%{oname}


%changelog
* Wed Aug 12 2020 Pavel Skrylev <majioa@altlinux.org> 1.7.5-alt1
- initial build for Sisyphus
