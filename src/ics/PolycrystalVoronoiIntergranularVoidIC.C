//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "PolycrystalVoronoiIntergranularVoidIC.h"

// MOOSE includes
#include "FEProblem.h"

#include "MooseMesh.h"
#include "MooseVariable.h"
#include "DelimitedFileReader.h"
#include "GrainTrackerInterface.h"
#include "PolycrystalVoronoi.h"
#include "PolycrystalHex.h"

#include "libmesh/utility.h"

InputParameters
PolycrystalVoronoiIntergranularVoidIC::actionParameters()
{
  InputParameters params = InitialCondition::validParams();
  params.addRequiredParam<Real>("invalue", "The variable value inside the circle");
  params.addRequiredParam<Real>("outvalue", "The variable value outside the circle");
  params.addParam<Real>(
      "int_width", 0.0, "The interfacial width of the void surface.  Defaults to sharp interface");
  params.addParam<bool>("3D_spheres", true, "in 3D, whether the voids are spheres or cylinders");
  params.addParam<bool>("columnar_grains", false, "in 3D, whether the grains are columnar");
  params.addParam<bool>("zero_gradient",
                        false,
                        "Set the gradient DOFs to zero. This can avoid "
                        "numerical problems with higher order shape "
                        "functions and overlapping circles.");
  params.addParam<unsigned int>("rand_seed", 12345, "Seed value for the random number generator");
  MooseEnum profileType("COS TANH", "COS");
  params.addParam<MooseEnum>(
      "profile", profileType, "Functional dependence for the interface profile");
  params.addRequiredParam<unsigned int>("numfacebub", "The number of bubbles to place");
  params.addRequiredParam<Real>("facebubspac",
                                "minimum spacing of bubbles, measured from center to center");
  params.addRequiredParam<unsigned int>("numcornerbub", "The number of bubbles to place");
  params.addRequiredParam<Real>("cornerbubspac",
                                "minimum spacing of bubbles, measured from center to center");
  params.addParam<unsigned int>("numtries", 1000, "The number of tries");
  params.addRequiredParam<Real>("faceradius", "Mean faceradius value for the circles");
  params.addParam<Real>("faceradius_variation",
                        0.0,
                        "Plus or minus fraction of random variation in "
                        "the bubble faceradius for uniform, standard "
                        "deviation for normal");
  params.addRequiredParam<Real>("cornerradius", "Mean cornerradius value for the circles");
  params.addParam<Real>("cornerradius_variation",
                        0.0,
                        "Plus or minus fraction of random variation in "
                        "the bubble cornerradius for uniform, standard "
                        "deviation for normal");
  MooseEnum rand_options("uniform normal none", "none"); // need to have diff. for face, corner
  params.addParam<MooseEnum>("faceradius_variation_type",
                             rand_options,
                             "Type of distribution that random circle faceradii will follow");
  params.addParam<MooseEnum>("cornerradius_variation_type",
                             rand_options,
                             "Type of distribution that random circle cornerradii will follow");
  params.addRequiredParam<unsigned int>("op_num", "Number of order parameters");
  return params;
}

registerMooseObject("UMoPFAEHMooseApp", PolycrystalVoronoiIntergranularVoidIC);

InputParameters
PolycrystalVoronoiIntergranularVoidIC::validParams()
{
  InputParameters params = PolycrystalVoronoiIntergranularVoidIC::actionParameters();
  params.addRequiredParam<UserObjectName>(
      "polycrystal_ic_uo", "UserObject for obtaining the polycrystal grain structure.");
  MooseEnum periodic_graincenters_option("true false", "true");
  params.addParam<MooseEnum>("periodic_graincenters",
                             periodic_graincenters_option,
                             "Option to opt out of generating periodic graincenters. Defaults to "
                             "true when periodic boundary conditions are used.");
  return params;
}

PolycrystalVoronoiIntergranularVoidIC::PolycrystalVoronoiIntergranularVoidIC(const InputParameters & parameters)
  : InitialCondition(parameters),
  _mesh(_fe_problem.mesh()),
  _invalue(parameters.get<Real>("invalue")),
  _outvalue(parameters.get<Real>("outvalue")),
  _int_width(parameters.get<Real>("int_width")),
  _3D_spheres(parameters.get<bool>("3D_spheres")),
  _is_columnar_grains(parameters.get<bool>("columnar_grains")),
  _zero_gradient(parameters.get<bool>("zero_gradient")),
  _num_dim(_3D_spheres ? 3 : 2),
  _profile(getParam<MooseEnum>("profile").getEnum<ProfileType>()),
  _numfacebub(getParam<unsigned int>("numfacebub")),
  _facebubspac(getParam<Real>("facebubspac")),
  _numcornerbub(getParam<unsigned int>("numcornerbub")),
  _cornerbubspac(getParam<Real>("cornerbubspac")),
  _max_num_tries(getParam<unsigned int>("numtries")),
  _faceradius(getParam<Real>("faceradius")),
  _faceradius_variation(getParam<Real>("faceradius_variation")),
  _faceradius_variation_type(getParam<MooseEnum>("faceradius_variation_type")),
  _cornerradius(getParam<Real>("cornerradius")),
  _cornerradius_variation(getParam<Real>("cornerradius_variation")),
  _cornerradius_variation_type(getParam<MooseEnum>("cornerradius_variation_type")),
  _op_num(getParam<unsigned int>("op_num")),
  _poly_ic_uo(getUserObject<PolycrystalVoronoi>("polycrystal_ic_uo")),
  _periodic_graincenters_option(getParam<MooseEnum>("periodic_graincenters")),
  _dim(_mesh.dimension())
{
  _random.seed(_tid, getParam<unsigned int>("rand_seed"));

  if (_int_width <= 0.0 && _profile == ProfileType::TANH)
    paramError("int_width",
               "Interface width has to be strictly positive for the hyperbolic tangent profile");

  if (_invalue < _outvalue)
    mooseWarning("Detected invalue < outvalue in PolycrystalVoronoiIntergranularVoidIC. Please make sure that's "
                 "the intended usage for representing voids.");
}

void
PolycrystalVoronoiIntergranularVoidIC::initialSetup()
{
  // Obtain total number and centerpoints of the grains
  _grain_num = _poly_ic_uo.getNumGrains();
  _centerpoints = _poly_ic_uo.getGrainCenters();

  // Set up domain bounds with mesh tools
  for (unsigned int i = 0; i < LIBMESH_DIM; ++i)
  {
    _bottom_left(i) = _mesh.getMinInDimension(i);
    _top_right(i) = _mesh.getMaxInDimension(i);
  }
  _range = _top_right - _bottom_left;

  if (_cornerradius_variation > 0.0 && _cornerradius_variation_type == 2)
    mooseError("If faceradius_variation > 0.0, you must pass in a faceradius_variation_type in "
               "MultiSmoothCircleIC");
  if (_cornerradius_variation > 0.0 && _cornerradius_variation_type == 2)
    mooseError("If cornerradius_variation > 0.0, you must pass in a cornerradius_variation_type in "
               "MultiSmoothCircleIC");

  computeCornerCircleRadii();
  computeFaceCircleRadii();

  // unsigned int _pbc_grain_num;
  unsigned int num_cells = 0;
  unsigned int dim = _dim;
  unsigned int rank = _dim + 1;

  if (_is_columnar_grains)
  {
    dim -= 1;
    rank -= 1;
  }

  switch (_periodic_graincenters_option)
  {
    case 0: // default
      // Check if periodic BC is applicable
      for (unsigned int op = 0; op < _op_num; ++op)
        for (unsigned int i = 0; i < dim; ++i)
          if (!_mesh.isTranslatedPeriodic(op, i))
            _pbc = false;
      break;
    case 1: // false
      _pbc = false;
  }

  // If periodic BC is applicable, generate grain centers in periodic domains
  if (_pbc == true)
  {
    Point translate;

    translate(0) = 0;
    translate(1) = 1;
    translate(2) = -1;

    if (_dim == 2 || _is_columnar_grains)
      num_cells = 9;
    else if (_dim == 3 && !_is_columnar_grains)
      num_cells = 27;

    _pbc_grain_num = num_cells * _grain_num;
    _pbc_centerpoints.resize(_pbc_grain_num);

    int cell = -1;
    for (unsigned int i = 0; i < 3; ++i)
      for (unsigned int j = 0; j < 3; ++j)
        if (_dim == 2 || _is_columnar_grains)
        {
          cell += 1;
          for (unsigned int gr = cell * _grain_num; gr < (cell + 1) * _grain_num; ++gr)
          {
            _pbc_centerpoints[gr](0) =
                _centerpoints[gr - cell * _grain_num](0) + translate(i) * _top_right(0);
            _pbc_centerpoints[gr](1) =
                _centerpoints[gr - cell * _grain_num](1) + translate(j) * _top_right(1);

            if (_is_columnar_grains == true)
              _pbc_centerpoints[gr](2) = _centerpoints[gr - cell * _grain_num](2);
          }
        }
        else if (_dim == 3 && !_is_columnar_grains)
        {
          for (unsigned int k = 0; k < 3; ++k)
          {
            cell += 1;
            for (unsigned int gr = cell * _grain_num; gr < (cell + 1) * _grain_num; ++gr)
            {
              _pbc_centerpoints[gr](0) =
                  _centerpoints[gr - cell * _grain_num](0) + translate(i) * _top_right(0);
              _pbc_centerpoints[gr](1) =
                  _centerpoints[gr - cell * _grain_num](1) + translate(j) * _top_right(1);
              _pbc_centerpoints[gr](2) =
                  _centerpoints[gr - cell * _grain_num](2) + translate(k) * _top_right(2);
            }
          }
        }
  }
  else // If not periodic, just use grain centers in current domain
  {
    num_cells = 1;

    _pbc_grain_num = num_cells * _grain_num;
    _pbc_centerpoints.resize(_pbc_grain_num);
    _pbc_centerpoints = _centerpoints;
  }

  computeCornerCircleCenters();
  computeFaceCircleCenters();
}

void
PolycrystalVoronoiIntergranularVoidIC::computeCornerCircleRadii()
{
  _cornerradii.resize(_numcornerbub);

  for (unsigned int i = 0; i < _numcornerbub; i++)
  {
    // Vary bubble cornerradius
    switch (_cornerradius_variation_type)
    {
      case 0: // Uniform distribution
        _cornerradii[i] = _cornerradius * (1.0 + (1.0 - 2.0 * _random.rand(_tid)) * _cornerradius_variation);
        break;
      case 1: // Normal distribution
        _cornerradii[i] = _random.randNormal(_tid, _cornerradius, _cornerradius_variation);
        break;
      case 2: // No variation
        _cornerradii[i] = _cornerradius;
    }

    _cornerradii[i] = std::max(_cornerradii[i], 0.0);
  }
}

void
PolycrystalVoronoiIntergranularVoidIC::computeFaceCircleRadii() 
{
  _faceradii.resize(_numfacebub);

  for (unsigned int i = 0; i < _numfacebub; i++)
  {
    // Vary bubble faceradius
    switch (_faceradius_variation_type)
    {
      case 0: // Uniform distribution
        _faceradii[i] = _faceradius * (1.0 + (1.0 - 2.0 * _random.rand(_tid)) * _faceradius_variation);
        break;
      case 1: // Normal distribution
        _faceradii[i] = _random.randNormal(_tid, _faceradius, _faceradius_variation);
        break;
      case 2: // No variation
        _faceradii[i] = _faceradius;
    }

    _faceradii[i] = std::max(_faceradii[i], 0.0);
  }
}

void
PolycrystalVoronoiIntergranularVoidIC::computeCornerCircleCenters()
{
  _cornercenters.resize(_numcornerbub);

  for (unsigned int vp = 0; vp < _numcornerbub; ++vp)
  {
    bool try_again;
    unsigned int num_tries = 0;

    do
    {
      try_again = false;
      num_tries++;

      if (num_tries > _max_num_tries)
        mooseError("Too many tries of assigning void centers in "
                   "PolycrystalVoronoiTJVoidIC");

      Point rand_point;

      for (unsigned int i = 0; i < LIBMESH_DIM; ++i)
        rand_point(i) = _bottom_left(i) + _range(i) * _random.rand(_tid);

      // Search and sort nearest grain centers to a random point (i.e. void center point)
      std::vector<PolycrystalVoronoiIntergranularVoidIC::DistancePoint> diff(_pbc_grain_num);

      for (unsigned int gr = 0; gr < _pbc_grain_num; ++gr)
      {
        diff[gr].d = (rand_point - _pbc_centerpoints[gr]).norm();
        diff[gr].gr = gr;
      }

      std::sort(diff.begin(), diff.end(), _customLess);

      Point closest_point = _pbc_centerpoints[diff[0].gr];
      Point next_closest_point = _pbc_centerpoints[diff[1].gr];
      Point third_closest_point = _pbc_centerpoints[diff[2].gr];

      Point vertex;

      // Locate voronoi vertex by searching nearest three grain centers
      // Project the random point on to the vertex (TJ point)
      if (_dim == 2 || _is_columnar_grains)
      {
        // Check area to see if points are non-collinear
        Real area = closest_point(0) * (next_closest_point(1) - third_closest_point(1)) 
                  + next_closest_point(0) * (third_closest_point(1) - closest_point(1)) 
                  + third_closest_point(0) * (closest_point(1) - next_closest_point(1)); 

        if (MooseUtils::isZero(area))
          try_again = true;
        else
        {
          _cornercenters[vp] = MathUtils::circumcenter2D(closest_point, next_closest_point, third_closest_point);
         
          if (_is_columnar_grains)
            _cornercenters[vp](2) = rand_point(2);
        }
      }

      // Locate voronoi vertex by searching nearest four grain centers
      // Project the random point on to the nearest TJ line
      if (_dim == 3 && !_is_columnar_grains)
      {
        Point fourth_closest_point = _pbc_centerpoints[diff[3].gr];

        vertex = MathUtils::circumcenter3D(closest_point, next_closest_point, third_closest_point, fourth_closest_point);

        if (std::isnan(vertex(0)))
          try_again = true;

        if (!try_again)
        {
          Point diff_pbc_centerpoints = next_closest_point - closest_point;
          Point diff_next_pbc_centerpoints = third_closest_point - closest_point;

          Point unit_cornercenters =
              diff_pbc_centerpoints / std::sqrt(diff_pbc_centerpoints * diff_pbc_centerpoints);
          Point unit_next_cornercenters =
              diff_next_pbc_centerpoints /
              std::sqrt(diff_next_pbc_centerpoints * diff_next_pbc_centerpoints);

          Real lambda = 0;

          Point corner_vector = unit_next_cornercenters.cross(unit_cornercenters);
          Point unit_corner_vector = corner_vector / std::sqrt(corner_vector * corner_vector);

          Point vertex_rand_vector = rand_point - vertex;

          for (unsigned int i = 0; i < LIBMESH_DIM; ++i)
          {
            lambda += (vertex_rand_vector(i) * unit_corner_vector(i));
          }

          _cornercenters[vp] = vertex + lambda * unit_corner_vector;
        }
      }

      // Check if void centers are within domain
      if (try_again == false)
        for (unsigned int i = 0; i < LIBMESH_DIM; i++)
          if ((_cornercenters[vp](i) > _top_right(i)) || (_cornercenters[vp](i) < _bottom_left(i)))
            try_again = true;

      // Check whether voids centers at TJs - equidistant to three grain centers
      if (try_again == false)
      {
        Real min_rij_1, min_rij_2, min_rij_3, rij, rij_diff_tol;

        min_rij_1 = _range.norm();
        min_rij_2 = min_rij_1;
        min_rij_3 = min_rij_1;

        rij_diff_tol = 0.1 * _cornerradius;

        for (unsigned int gr = 0; gr < _pbc_grain_num; ++gr)
        {
          rij = (_cornercenters[vp] - _pbc_centerpoints[gr]).norm();

          if (rij < min_rij_1)
          {
            min_rij_3 = min_rij_2;
            min_rij_2 = min_rij_1;
            min_rij_1 = rij;
          }
          else if (rij < min_rij_2)
            min_rij_2 = rij;
          else if (rij < min_rij_3)
            min_rij_3 = rij;
        }

        if (std::abs(min_rij_1 - min_rij_2) > rij_diff_tol ||
            std::abs(min_rij_2 - min_rij_3) > rij_diff_tol ||
            std::abs(min_rij_1 - min_rij_3) > rij_diff_tol)
          try_again = true;
      }

      if (try_again == false)
      {
        for (unsigned int i = 0; i < vp; ++i)
        {
          Real dist = _mesh.minPeriodicDistance(_var.number(), _cornercenters[vp], _cornercenters[i]);

          if (dist < _cornerbubspac)
            try_again = true;
        }
      }

    } while (try_again == true);
  }
}

void
PolycrystalVoronoiIntergranularVoidIC::computeFaceCircleCenters() 
{

  _facecenters.resize(_numfacebub);

  // This code will place void center points on grain boundaries
  for (unsigned int vp = 0; vp < _numfacebub; ++vp)
  {
    bool try_again;
    unsigned int num_tries = 0;

    do
    {
      try_again = false;
      num_tries++;

      if (num_tries > _max_num_tries)
        mooseError("Too many tries of assigning void centers in "
                   "PolycrystalVoronoiVoidIC");

      Point rand_point;

      for (unsigned int i = 0; i < LIBMESH_DIM; ++i)
        rand_point(i) = _bottom_left(i) + _range(i) * _random.rand(_tid);

      std::vector<PolycrystalVoronoiIntergranularVoidIC::DistancePoint> diff(_pbc_grain_num);

      for (unsigned int gr = 0; gr < _pbc_grain_num; ++gr) 
      {
        diff[gr].d = (rand_point - _pbc_centerpoints[gr]).norm();
        diff[gr].gr = gr;
      }

      std::sort(diff.begin(), diff.end(), _customLess);

      Point closest_point = _pbc_centerpoints[diff[0].gr];
      Point next_closest_point = _pbc_centerpoints[diff[1].gr];

      // Find Slope of Line in the plane orthogonal to the diff_centerpoint
      Point pa = rand_point + _mesh.minPeriodicVector(_var.number(), rand_point, closest_point);
      Point pb =
          rand_point + _mesh.minPeriodicVector(_var.number(), rand_point, next_closest_point);
      Point diff_centerpoints = pb - pa;

      Point diff_rand_center = _mesh.minPeriodicVector(_var.number(), closest_point, rand_point);
      Point normal_vector = diff_centerpoints.cross(diff_rand_center);
      Point slope = normal_vector.cross(diff_centerpoints);

      // Midpoint position vector between two center points
      Point midpoint = closest_point + (0.5 * diff_centerpoints);

      // Solve for the scalar multiplier solution on the line
      Real lambda = 0;

      Point mid_rand_vector = _mesh.minPeriodicVector(_var.number(), midpoint, rand_point);

      Real slope_dot = slope * slope;
      mooseAssert(slope_dot > 0, "The dot product of slope with itself is zero");

      for (unsigned int i = 0; i < LIBMESH_DIM; ++i)
        lambda += (mid_rand_vector(i) * slope(i)) / slope_dot;

      // Assigning points to vector
      _facecenters[vp] = slope * lambda + midpoint;

      // Checking to see if points are in the domain
      for (unsigned int i = 0; i < LIBMESH_DIM; i++)
        if ((_facecenters[vp](i) > _top_right(i)) || (_facecenters[vp](i) < _bottom_left(i)))
          try_again = true;

      // Use circle center for checking whether voids are at GBs
      if (try_again == false)
      {
        Real min_rij_1, min_rij_2, rij, rij_diff_tol;

        min_rij_1 = _range.norm();
        min_rij_2 = _range.norm();

        rij_diff_tol = 0.1 * _faceradius;

        for (unsigned int gr = 0; gr < _pbc_grain_num; ++gr)
        {
          rij = (_facecenters[vp] - _pbc_centerpoints[gr]).norm();
          // rij = _mesh.minPeriodicDistance(_var.number(), _facecenters[vp], _centerpoints[gr]);

          if (rij < min_rij_1)
          {
            min_rij_2 = min_rij_1;
            min_rij_1 = rij;
          }
          else if (rij < min_rij_2)
            min_rij_2 = rij;
        }

        if (std::abs(min_rij_1 - min_rij_2) > rij_diff_tol)
          try_again = true;
      }

      // Void is on face but shouldn't be close to corner
      if (try_again == false) 
      {
        Real min_rij_1, min_rij_2, min_rij_3, rij, rij_diff_tol;

        min_rij_1 = _range.norm();
        min_rij_2 = _range.norm();
        min_rij_3 = _range.norm();

        for (unsigned int gr = 0; gr < _pbc_grain_num; ++gr)
        {
          rij = (_facecenters[vp] - _pbc_centerpoints[gr]).norm();
          // rij = _mesh.minPeriodicDistance(_var.number(), _facecenters[vp], _centerpoints[gr]);

          if (rij < min_rij_1)
          {
            min_rij_3 = min_rij_2; 
            min_rij_2 = min_rij_1;
            min_rij_1 = rij;
          }
          else if (rij < min_rij_2)
            min_rij_2 = rij;
          else if (rij < min_rij_3)
            min_rij_3 = rij;
        }

        rij_diff_tol = 0.1 * _faceradius;;

        if (std::abs(min_rij_1 - min_rij_2) < rij_diff_tol &&
            std::abs(min_rij_2 - min_rij_3) < rij_diff_tol &&
            std::abs(min_rij_1 - min_rij_3) < rij_diff_tol)
          try_again = true;
      }

      for (unsigned int i = 0; i < vp; ++i)
      {
        Real dist = _mesh.minPeriodicDistance(_var.number(), _facecenters[vp], _facecenters[i]);
        // Real dist = (_facecenters[vp] - _facecenters[i]).norm(); // SBK modified
  
        if (dist < _facebubspac)
          try_again = true;
        
        Real inter_dist = (_facecenters[vp] - _cornercenters[i]).norm();

        if (try_again == false && inter_dist < 0.5 * (_cornerbubspac + _facebubspac))
          try_again = true;
      }
    
    } while (try_again == true);
  }
}

Real
PolycrystalVoronoiIntergranularVoidIC::value(const Point & p)
{
  Real value = 0.0;

  Real void_value = _outvalue;
  Real val = 0.0;

  for (unsigned int vp = 0; vp < _numfacebub && void_value != _invalue; ++vp)
  {
    val = computeCircleValue(p, _facecenters[vp], _faceradii[vp]);
    if ((val > void_value && _invalue > _outvalue) || (val < void_value && _outvalue > _invalue))
      void_value = val;
  }

  for (unsigned int vp = 0; vp < _numcornerbub && void_value != _invalue; ++vp) 
  {
    val = computeCircleValue(p, _cornercenters[vp], _cornerradii[vp]);
    if ((val > void_value && _invalue > _outvalue) || (val < void_value && _outvalue > _invalue))
      void_value = val;
  }

  value = void_value;

  return value;
}

RealGradient
PolycrystalVoronoiIntergranularVoidIC::gradient(const Point & p)
{
  RealGradient gradient;

  if (_zero_gradient)
    return 0.0;

  RealGradient void_gradient = 0.0;
  Real value = _outvalue;
  Real val = 0.0;

  for (unsigned int vp = 0; vp < _numfacebub; ++vp)
  {
    val = computeCircleValue(p, _facecenters[vp], _faceradii[vp]);
    if ((val > value && _invalue > _outvalue) || (val < value && _outvalue > _invalue))
    {
      value = val;
      void_gradient = computeCircleGradient(p, _facecenters[vp], _faceradii[vp]);
    }
  }

  for (unsigned int vp = 0; vp < _numcornerbub; ++vp)
  {
    val = computeCircleValue(p, _cornercenters[vp], _cornerradii[vp]);
    if ((val > value && _invalue > _outvalue) || (val < value && _outvalue > _invalue))
    {
      value = val;
      void_gradient = computeCircleGradient(p, _cornercenters[vp], _cornerradii[vp]); 
    }
  }

  gradient = void_gradient;

  return gradient;
}

Real
PolycrystalVoronoiIntergranularVoidIC::computeCircleValue(const Point & p, const Point & center, const Real & radius)
{
  Point l_center = center; // from _cornercenters[vp]
  Point l_p = p;
  if (!_3D_spheres) // Create 3D cylinders instead of spheres
  {
    l_p(2) = 0.0;
    l_center(2) = 0.0;
  }
  // Compute the distance between the current point and the center
  Real dist = _mesh.minPeriodicDistance(_var.number(), l_p, l_center); 

  switch (_profile)
  {
    case ProfileType::COS:
    {
      // Return value
      Real value = _outvalue; // Outside circle

      if (dist <= radius - _int_width / 2.0) // Inside circle
        value = _invalue;
      else if (dist < radius + _int_width / 2.0) // Smooth interface
      {
        Real int_pos = (dist - radius + _int_width / 2.0) / _int_width;
        value = _outvalue + (_invalue - _outvalue) * (1.0 + std::cos(int_pos * libMesh::pi)) / 2.0;
      }
      return value;
    }

    case ProfileType::TANH:
      return (_invalue - _outvalue) * 0.5 * (std::tanh(2.0 * (radius - dist) / _int_width) + 1.0) +
             _outvalue;

    default:
      mooseError("Internal error.");
  }
}

RealGradient
PolycrystalVoronoiIntergranularVoidIC::computeCircleGradient(const Point & p,
                                          const Point & center,
                                          const Real & radius)
{
  Point l_center = center;
  Point l_p = p;
  if (!_3D_spheres) // Create 3D cylinders instead of spheres
  {
    l_p(2) = 0.0;
    l_center(2) = 0.0;
  }
  // Compute the distance between the current point and the center
  Real dist = _mesh.minPeriodicDistance(_var.number(), l_p, l_center);

    // early return if we are probing the center of the circle
  if (dist == 0.0)
    return 0.0;

  Real DvalueDr = 0.0;
  switch (_profile)
  {
    case ProfileType::COS:
      if (dist < radius + _int_width / 2.0 && dist > radius - _int_width / 2.0)
      {
        const Real int_pos = (dist - radius + _int_width / 2.0) / _int_width;
        const Real Dint_posDr = 1.0 / _int_width;
        DvalueDr = Dint_posDr * (_invalue - _outvalue) *
                   (-std::sin(int_pos * libMesh::pi) * libMesh::pi) / 2.0;
      }
      break;

    case ProfileType::TANH:
      DvalueDr = -(_invalue - _outvalue) * 0.5 / _int_width * libMesh::pi *
                 (1.0 - Utility::pow<2>(std::tanh(4.0 * (radius - dist) / _int_width)));
      break;

    default:
      mooseError("Internal error.");
  }

  return _mesh.minPeriodicVector(_var.number(), center, p) * (DvalueDr / dist);
}
