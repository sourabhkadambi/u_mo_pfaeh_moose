[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 10
  ny = 10
  xmax = 10
  ymax = 10
  uniform_refine = 1
[]

[GlobalParams]
  op_num = 8
  var_name_base = gr
  grain_num = 8

  int_width = 0.125

  numfacebub = 20
  facebubspac = 1
  faceradius = 0.25

  numcornerbub = 5
  cornerbubspac = 2
  cornerradius = 0.5

  invalue = 1
  outvalue = 0
  numtries = 1e6
  use_kdtree = true


[]

[Variables]
  [./PolycrystalVariables]
  [../]
[]

[AuxVariables]
  [./void]
  [../]
  [./bnds]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[UserObjects]
  [./voronoi_ic_uo]
    type = PolycrystalVoronoi
    coloring_algorithm = bt
    rand_seed = 12345
  [../]
[]

[ICs]
  [./PolycrystalICs]
    [./PolycrystalVoronoiCoupledVoidIC]
      v = void
      polycrystal_ic_uo = voronoi_ic_uo
    [../]
  [../]
  [./void]
    type = PolycrystalVoronoiIntergranularVoidIC
    variable = void
    polycrystal_ic_uo = voronoi_ic_uo
  [../]
  [./bnds]
    type = BndsCalcIC
    variable = bnds
  [../]
[]

[BCs]
  [./Periodic]
    [./all]
      auto_direction = 'x y'
    [../]
  [../]
[]

[Executioner]
  type = Transient
  num_steps = 1
[]

[Problem]
  solve = false
  kernel_coverage_check = false
[]

[Outputs]
  [./out]
    type = Exodus
    execute_on = final
  [../]
[]
