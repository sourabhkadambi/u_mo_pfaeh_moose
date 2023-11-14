//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "InitialCondition.h"
#include "MooseRandom.h"
#include "PolycrystalICTools.h"

// Forward Declarationsc
class GrainTrackerInterface;
class PolycrystalVoronoi;

/**
 * PolycrystalVoronoiIntergranularVoidIC initializes either grain or void values for a
 * voronoi tesselation with voids distributed along the grain boundaries and triple junctions.
 */
class PolycrystalVoronoiIntergranularVoidIC : public InitialCondition
{
public:
  static InputParameters validParams();
  static InputParameters actionParameters();

  PolycrystalVoronoiIntergranularVoidIC(const InputParameters & parameters);

  virtual Real value(const Point & p);
  virtual RealGradient gradient(const Point & p);

  virtual void initialSetup();

protected:

  virtual Real computeCircleValue(const Point & p, const Point & center, const Real & radius);
  virtual RealGradient
  computeCircleGradient(const Point & p, const Point & center, const Real & radius);

  virtual void computeFaceCircleRadii();
  virtual void computeFaceCircleCenters();
  virtual void computeCornerCircleRadii();
  virtual void computeCornerCircleCenters();

  MooseMesh & _mesh;

  Real _invalue;
  Real _outvalue;
  Real _int_width;
  bool _3D_spheres;
  bool _is_columnar_grains;
  bool _zero_gradient;

  bool _pbc = true; // default
  unsigned int _num_dim;

  std::vector<Point> _facecenters;
  std::vector<Real> _faceradii;
  std::vector<Point> _cornercenters;
  std::vector<Real> _cornerradii;

  enum class ProfileType
  {
    COS,
    TANH
  } _profile;

  MooseRandom _random;

  const unsigned int _numfacebub;
  const Real _facebubspac;
  const unsigned int _numcornerbub;
  const Real _cornerbubspac;

  const unsigned int _max_num_tries;

  const Real _faceradius;
  const Real _faceradius_variation;
  const MooseEnum _faceradius_variation_type;
  const Real _cornerradius;
  const Real _cornerradius_variation;
  const MooseEnum _cornerradius_variation_type;

  Point _bottom_left;
  Point _top_right;
  Point _range;

  const unsigned int _op_num;

  const PolycrystalVoronoi & _poly_ic_uo;

  const MooseEnum _periodic_graincenters_option;

  const unsigned int _dim;

  unsigned int _grain_num;
  unsigned int _pbc_grain_num;

  std::vector<Point> _centerpoints;
  std::vector<Point> _pbc_centerpoints;

  /// Type for distance and point
  struct DistancePoint
  {
    Real d;
    unsigned int gr;
  };

  /// Sorts the temp_centerpoints into order of magnitude
  struct DistancePointComparator
  {
    bool operator()(const DistancePoint & a, const DistancePoint & b) { return a.d < b.d; }
  } _customLess;
};
