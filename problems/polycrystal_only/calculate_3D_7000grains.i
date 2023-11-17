[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 50
  ny = 50 
  nz = 50
  xmax = 5317 
  ymax = 5317 
  zmax = 5317
  elem_type = HEX8
[]

[GlobalParams]
  op_num = 100
 grain_num = 7000
  var_name_base = etam
  int_width = 93.4
  use_kdtree = true
[]

[Variables]
  [./PolycrystalVariables]
  [../]

  [./dx_xx]
  [../]
  [./dx_yy]
  [../]
  [./dx_zz]
  [../]
  [./dx_xy]
  [../]
  [./dx_xz]
  [../]
  [./dx_yz]
  [../]

  [./dy_xx]
  [../]
  [./dy_yy]
  [../]
  [./dy_zz]
  [../]
  [./dy_xy]
  [../]
  [./dy_xz]
  [../]
  [./dy_yz]
  [../]

  [./dz_xx]
  [../]
  [./dz_yy]
  [../]
  [./dz_zz]
  [../]
  [./dz_xy]
  [../]
  [./dz_xz]
  [../]
  [./dz_yz]
  [../]
[]

[AuxVariables]
  [./bnds]
    order = FIRST
    family = LAGRANGE
  [../]
  [./unique_grains]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./elastic_strain_11]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./elastic_strain_12]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_11]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_12]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./C1111]
    order = CONSTANT
    family = MONOMIAL
   [../]
  [./C1122]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./C1212]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[ICs]
  [./PolycrystalICs]
    [./PolycrystalColoringIC]
      polycrystal_ic_uo = voronoi_ic_uo
    [../]
  [../]
[]

[UserObjects]
  [./voronoi_ic_uo]
    type = PolycrystalVoronoi
    coloring_algorithm = jp 
  [../]
 [./euler_angle_file]
   type = EulerAngleFileReader
   file_name =  np_grn_7000_rand360rot3_3D_rand1.tex
 [../]
 [./grain_tracker]
   type = GrainTrackerElasticity
   threshold = 0.2
   flood_entity_type = ELEMENTAL
   compute_halo_maps = true
   compute_var_to_feature_map = true
   execute_on = 'initial'
   flood_entity_type = ELEMENTAL
   fill_method = symmetric9
   C_ijkl = '140.2239 89.5744 89.5744 140.2239 89.5744 140.2239 38.7262 38.7262 38.7262'
   euler_angle_provider = euler_angle_file
   outputs = csv
 [../]
[]

[BCs]
  [./Periodic]
    [./All]
      auto_direction = 'x y z'
    [../]
  [../]
  [./dy_xx_top_bottom]
    type = DirichletBC
    variable = dy_xx
    boundary = 'top bottom'
    value = 0
  [../]
  [./dy_yy_top_bottom]
    type = DirichletBC
    variable = dy_yy
    boundary = 'top bottom'
    value = 0
  [../]
  [./dy_zz_top_bottom]
    type = DirichletBC
    variable = dy_zz
    boundary = 'top bottom'
    value = 0
  [../]
  [./dy_xy_top_bottom]
    type = DirichletBC
    variable = dy_xy
    boundary = 'top bottom'
    value = 0
  [../]
  [./dy_xz_top_bottom]
    type = DirichletBC
    variable = dy_xz
    boundary = 'top bottom'
    value = 0
  [../]
  [./dy_yz_top_bottom]
    type = DirichletBC
    variable = dy_yz
    boundary = 'top bottom'
    value = 0
  [../]

  [./dx_xx_left_right]
    type = DirichletBC
    variable = dx_xx
    boundary = 'left right'
    value = 0.0
  [../]
  [./dx_yy_left_right]
    type = DirichletBC
    variable = dx_yy
    boundary = 'left right'
    value = 0.0
  [../]
  [./dx_zz_left_right]
    type = DirichletBC
    variable = dx_zz
    boundary = 'left right'
    value = 0.0
  [../]
  [./dx_xy_left_right]
    type = DirichletBC
    variable = dx_xy
    boundary = 'left right'
    value = 0.0
  [../]
  [./dx_xz_left_right]
    type = DirichletBC
    variable = dx_xz
    boundary = 'left right'
    value = 0.0
  [../]
  [./dx_yz_left_right]
    type = DirichletBC
    variable = dx_yz
    boundary = 'left right'
    value = 0.0
  [../]

  [./dz_xx_left_right]
    type = DirichletBC
    variable = dz_xx
    boundary = 'front back'
    value = 0.0
  [../]
  [./dz_yy_left_right]
    type = DirichletBC
    variable = dz_yy
    boundary = 'front back'
    value = 0.0
  [../]
  [./dz_zz_left_right]
    type = DirichletBC
    variable = dz_zz
    boundary = 'front back'
    value = 0.0
  [../]
  [./dz_xy_left_right]
    type = DirichletBC
    variable = dz_xy
    boundary = 'front back'
    value = 0.0
  [../]
  [./dz_xz_left_right]
    type = DirichletBC
    variable = dz_xz
    boundary = 'front back'
    value = 0.0
  [../]
  [./dz_yz_left_right]
    type = DirichletBC
    variable = dz_yz
    boundary = 'front back'
    value = 0.0
  [../]
[]

[Kernels]
  [./PolycrystalKernel]
  [../]

  [./aeh_dx_xx]
    type = AsymptoticExpansionHomogenizationKernel
    variable = dx_xx
    component = 0
    column = xx
    base_name = xx
  [../]
  [./aeh_dy_xx]
    type = AsymptoticExpansionHomogenizationKernel
    variable = dy_xx
    component = 1
    column = xx
    base_name = xx
  [../]
    [./aeh_dz_xx]
      type = AsymptoticExpansionHomogenizationKernel
      variable = dz_xx
      component = 2
      column = xx
      base_name = xx
    [../]
  [./aeh_dx_yy]
    type = AsymptoticExpansionHomogenizationKernel
    variable = dx_yy
    component = 0
    column = yy
    base_name = yy
  [../]
  [./aeh_dy_yy]
    type = AsymptoticExpansionHomogenizationKernel
    variable = dy_yy
    component = 1
    column = yy
    base_name = yy
  [../]
  [./aeh_dz_yy]
    type = AsymptoticExpansionHomogenizationKernel
    variable = dz_yy
    component = 2
    column = yy
    base_name = yy
  [../]
  [./aeh_dx_zz]
    type = AsymptoticExpansionHomogenizationKernel
    variable = dx_zz
    component = 0
    column = zz
    base_name = zz
  [../]
  [./aeh_dy_zz]
    type = AsymptoticExpansionHomogenizationKernel
    variable = dy_zz
    component = 1
    column = zz
    base_name = zz
  [../]
  [./aeh_dz_zz]
    type = AsymptoticExpansionHomogenizationKernel
    variable = dz_zz
    component = 2
    column = zz
    base_name = zz
  [../]
  [./aeh_dx_xy]
    type = AsymptoticExpansionHomogenizationKernel
    variable = dx_xy
    component = 0
    column = xy
    base_name = xy
  [../]
  [./aeh_dy_xy]
    type = AsymptoticExpansionHomogenizationKernel
    variable = dy_xy
    component = 1
    column = xy
    base_name = xy
  [../]
  [./aeh_dz_xy]
    type = AsymptoticExpansionHomogenizationKernel
    variable = dz_xy
    component = 2
    column = xy
    base_name = xy
  [../]
  [./aeh_dx_xz]
    type = AsymptoticExpansionHomogenizationKernel
    variable = dx_xz
    component = 0
    column = xz
    base_name = xz
  [../]
  [./aeh_dy_xz]
    type = AsymptoticExpansionHomogenizationKernel
    variable = dy_xz
    component = 1
    column = xz
    base_name = xz
  [../]
  [./aeh_dz_xz]
    type = AsymptoticExpansionHomogenizationKernel
    variable = dz_xz
    component = 2
    column = xz
    base_name = xz
  [../]
  [./aeh_dx_yz]
    type = AsymptoticExpansionHomogenizationKernel
    variable = dx_yz
    component = 0
    column = yz
    base_name = yz
  [../]
  [./aeh_dy_yz]
    type = AsymptoticExpansionHomogenizationKernel
    variable = dy_yz
    component = 1
    column = yz
    base_name = yz
  [../]
  [./aeh_dz_yz]
    type = AsymptoticExpansionHomogenizationKernel
    variable = dz_yz
    component = 2
    column = yz
    base_name = yz
  [../]

  [./div_x_xx]
    type = StressDivergenceTensors
    component = 0
    variable = dx_xx
    displacements = 'dx_xx dy_xx dz_xx'
    use_displaced_mesh = false
    base_name = xx
  [../]
  [./div_x_yy]
    type = StressDivergenceTensors
    component = 0
    variable = dx_yy
    displacements = 'dx_yy dy_yy dz_yy'
    use_displaced_mesh = false
    base_name = yy
  [../]
  [./div_x_zz]
    type = StressDivergenceTensors
    component = 0
    variable = dx_zz
    displacements = 'dx_zz dy_zz dz_zz'
    use_displaced_mesh = false
    base_name = zz
  [../]

  [./div_x_xy]
    type = StressDivergenceTensors
    component = 0
    variable = dx_xy
    displacements = 'dx_xy dy_xy dz_xy'
    use_displaced_mesh = false
    base_name = xy
  [../]
  [./div_x_xz]
    type = StressDivergenceTensors
    component = 0
    variable = dx_xz
    displacements = 'dx_xz dy_xz dz_xz'
    use_displaced_mesh = false
    base_name = xz
  [../]
  [./div_x_yz]
    type = StressDivergenceTensors
    component = 0
    variable = dx_yz
    displacements = 'dx_yz dy_yz dz_yz'
    use_displaced_mesh = false
    base_name = yz
  [../]

  [./div_y_xx]
    type = StressDivergenceTensors
    component = 1
    variable = dy_xx
    displacements = 'dx_xx dy_xx dz_xx'
    use_displaced_mesh = false
    base_name = xx
  [../]
  [./div_y_yy]
    type = StressDivergenceTensors
    component = 1
    variable = dy_yy
    displacements = 'dx_yy dy_yy dz_yy'
    use_displaced_mesh = false
    base_name = yy
  [../]
  [./div_y_zz]
    type = StressDivergenceTensors
    component = 1
    variable = dy_zz
    displacements = 'dx_zz dy_zz dz_zz'
    use_displaced_mesh = false
    base_name = zz
  [../]

  [./div_y_xy]
    type = StressDivergenceTensors
    component = 1
    variable = dy_xy
    displacements = 'dx_xy dy_xy dz_xy'
    use_displaced_mesh = false
    base_name = xy
  [../]
  [./div_y_xz]
    type = StressDivergenceTensors
    component = 1
    variable = dy_xz
    displacements = 'dx_xz dy_xz dz_xz'
    use_displaced_mesh = false
    base_name = xz
  [../]
  [./div_y_yz]
    type = StressDivergenceTensors
    component = 1
    variable = dy_yz
    displacements = 'dx_yz dy_yz dz_yz'
    use_displaced_mesh = false
    base_name = yz
  [../]

  [./div_z_xx]
    type = StressDivergenceTensors
    component = 2
    variable = dz_xx
    displacements = 'dx_xx dy_xx dz_xx'
    use_displaced_mesh = false
    base_name = xx
  [../]
  [./div_z_yy]
    type = StressDivergenceTensors
    component = 2
    variable = dz_yy
    displacements = 'dx_yy dy_yy dz_yy'
    use_displaced_mesh = false
    base_name = yy
  [../]
  [./div_z_zz]
    type = StressDivergenceTensors
    component = 2
    variable = dz_zz
    displacements = 'dx_zz dy_zz dz_zz'
    use_displaced_mesh = false
    base_name = zz
  [../]

  [./div_z_xy]
    type = StressDivergenceTensors
    component = 2
    variable = dz_xy
    displacements = 'dx_xy dy_xy dz_xy'
    use_displaced_mesh = false
    base_name = xy
  [../]
  [./div_z_xz]
    type = StressDivergenceTensors
    component = 2
    variable = dz_xz
    displacements = 'dx_xz dy_xz dz_xz'
    use_displaced_mesh = false
    base_name = xz
  [../]
  [./div_z_yz]
    type = StressDivergenceTensors
    component = 2
    variable = dz_yz
    displacements = 'dx_yz dy_yz dz_yz'
    use_displaced_mesh = false
    base_name = yz
  [../]
[]

[Materials]
  [./constants_U10Mo] 
    type = GenericConstantMaterial
    prop_names =  'kappa_op      L     D      mu        gamma_asymm ' 
    prop_values = '1.0547        1     1      0.0023    1.5         '
  [../]

  [./PolyGrElasticityTensor]
    type = ComputePolycrystalElasticityTensor 
    block = 0
    grain_tracker = grain_tracker
  [../]


  [./elastic_stress_xx]
    type = ComputeLinearElasticStress
    base_name = xx
  [../]
  [./elastic_stress_yy]
    type = ComputeLinearElasticStress
    base_name = yy
  [../]
  [./elastic_stress_zz]
    type = ComputeLinearElasticStress
    base_name = zz
  [../]
  [./elastic_stress_xy]
    type = ComputeLinearElasticStress
    base_name = xy
  [../]
  [./elastic_stress_xz]
    type = ComputeLinearElasticStress
    base_name = xz
  [../]
  [./elastic_stress_yz]
    type = ComputeLinearElasticStress
    base_name = yz
  [../]

  [./strain_xx]
    type = ComputeSmallStrain
    displacements = 'dx_xx dy_xx dz_xx'
    base_name = xx
  [../]
  [./strain_yy]
    type = ComputeSmallStrain
    displacements = 'dx_yy dy_yy dz_yy'
    base_name = yy
  [../]
  [./strain_zz]
    type = ComputeSmallStrain
    displacements = 'dx_zz dy_zz dz_zz'
    base_name = zz
  [../]
  [./strain_xy]
    type = ComputeSmallStrain
    displacements = 'dx_xy dy_xy dz_xy'
    base_name = xy
  [../]
  [./strain_xz]
    type = ComputeSmallStrain
    displacements = 'dx_xz dy_xz dz_xz'
    base_name = xz
  [../]
  [./strain_yz]
    type = ComputeSmallStrain
    displacements = 'dx_yz dy_yz dz_yz'
    base_name = yz
  [../]

  [./PolyGrElasticityTensor_xx]
    type = ComputePolycrystalElasticityTensor 
    block = 0
    grain_tracker = grain_tracker
    base_name = xx
  [../]
  [./PolyGrElasticityTensor_xy]
    type = ComputePolycrystalElasticityTensor 
    block = 0
    grain_tracker = grain_tracker
    base_name = xy
  [../]
  [./PolyGrElasticityTensor_yy]
    type = ComputePolycrystalElasticityTensor 
    block = 0
    grain_tracker = grain_tracker
    base_name = yy
  [../]
  [./PolyGrElasticityTensor_zz]
    type = ComputePolycrystalElasticityTensor 
    block = 0
    grain_tracker = grain_tracker
    base_name = zz
  [../]
  [./PolyGrElasticityTensor_yz]
    type = ComputePolycrystalElasticityTensor 
    block = 0
    grain_tracker = grain_tracker
    base_name = yz
  [../]
  [./PolyGrElasticityTensor_xz]
    type = ComputePolycrystalElasticityTensor 
    block = 0
    grain_tracker = grain_tracker
    base_name = xz
  [../]
[]

[AuxKernels]
  [./bnds_aux]
    type = BndsCalcAux
    variable = bnds
    execute_on = 'initial timestep_end'
  [../]
  [./unique_grains]
    type = FeatureFloodCountAux
    variable = unique_grains
    flood_counter = grain_tracker
    field_display = UNIQUE_REGION
    execute_on = 'initial timestep_end'
  [../]
  [./elastic_strain_11]
    type = RankTwoAux
    variable = elastic_strain_11
    rank_two_tensor = xx_elastic_strain
    index_i = 0
    index_j = 0
    execute_on = timestep_end
  [../]
  [./elastic_strain_12]
    type = RankTwoAux
    variable = elastic_strain_12
    rank_two_tensor = xx_elastic_strain
    index_i = 0
    index_j = 1
    execute_on = timestep_end
  [../]  
  [./stress_11]
    type = RankTwoAux
    variable = stress_11
    rank_two_tensor = xx_stress
    index_i = 0
    index_j = 0
    execute_on = timestep_end
  [../]
  [./stress_12]
    type = RankTwoAux
    variable = stress_12
    rank_two_tensor = xx_stress
    index_i = 0
    index_j = 1
    execute_on = timestep_end
  [../]
  [./C1111]
    type = RankFourAux
    variable = C1111
    rank_four_tensor = elasticity_tensor
    index_i = 0
    index_j = 0
    index_k = 0
    index_l = 0
    execute_on = timestep_end
  [../]
  [./C1122]
    type = RankFourAux
    variable = C1122
    rank_four_tensor = elasticity_tensor
    index_i = 0
    index_j = 0
    index_k = 1
    index_l = 1
    execute_on = timestep_end
  [../]
  [./C1212]
    type = RankFourAux
    variable = C1212
    rank_four_tensor = elasticity_tensor
    index_i = 0
    index_j = 1
    index_k = 0
    index_l = 1
    execute_on = timestep_end
  [../]
[]

[Postprocessors]
  [./dt]
    type = TimestepSize
  [../]
  [./dofs]
    type = NumDOFs
  [../]
  [./run_time]
    type = PerfGraphData
    section_name = "Root"
    data_type = total
  [../]
  [./bnd_length]
    type = GrainBoundaryArea
  [../]

  [./physical]
    type = MemoryUsage
    mem_type = physical_memory
    value_type = total
    execute_on = 'INITIAL TIMESTEP_END NONLINEAR LINEAR'
  [../]

  [./H1111]
    type = AsymptoticExpansionHomogenizationElasticConstants
    base_name = xx
    row = xx
    column = xx
    dx_xx = dx_xx
    dx_yy = dx_yy
    dx_zz = dx_zz
    dx_xy = dx_xy
    dx_yz = dx_yz
    dx_zx = dx_xz
    dy_xx = dy_xx
    dy_yy = dy_yy
    dy_zz = dy_zz
    dy_xy = dy_xy
    dy_yz = dy_yz
    dy_zx = dy_xz
    dz_xx = dz_xx
    dz_yy = dz_yy
    dz_zz = dz_zz
    dz_xy = dz_xy
    dz_yz = dz_yz
    dz_zx = dz_xz
    execute_on = 'timestep_end'
    outputs = 'exodus csv console'
  [../]
  [./H2222]
    type = AsymptoticExpansionHomogenizationElasticConstants
    base_name = yy
    row = yy
    column = yy
    dx_xx = dx_xx
    dx_yy = dx_yy
    dx_zz = dx_zz
    dx_xy = dx_xy
    dx_yz = dx_yz
    dx_zx = dx_xz
    dy_xx = dy_xx
    dy_yy = dy_yy
    dy_zz = dy_zz
    dy_xy = dy_xy
    dy_yz = dy_yz
    dy_zx = dy_xz
    dz_xx = dz_xx
    dz_yy = dz_yy
    dz_zz = dz_zz
    dz_xy = dz_xy
    dz_yz = dz_yz
    dz_zx = dz_xz
    execute_on = 'timestep_end'
    outputs = 'exodus csv console'
  [../]
  [./H3333]
    type = AsymptoticExpansionHomogenizationElasticConstants
    base_name = zz
    row = zz
    column = zz
    dx_xx = dx_xx
    dx_yy = dx_yy
    dx_zz = dx_zz
    dx_xy = dx_xy
    dx_yz = dx_yz
    dx_zx = dx_xz
    dy_xx = dy_xx
    dy_yy = dy_yy
    dy_zz = dy_zz
    dy_xy = dy_xy
    dy_yz = dy_yz
    dy_zx = dy_xz
    dz_xx = dz_xx
    dz_yy = dz_yy
    dz_zz = dz_zz
    dz_xy = dz_xy
    dz_yz = dz_yz
    dz_zx = dz_xz
    execute_on = 'timestep_end'
    outputs = 'exodus csv console'
  [../]
  [./H1122]
    type = AsymptoticExpansionHomogenizationElasticConstants
    base_name = yy
    row = xx
    column = yy
    dx_xx = dx_xx
    dx_yy = dx_yy
    dx_zz = dx_zz
    dx_xy = dx_xy
    dx_yz = dx_yz
    dx_zx = dx_xz
    dy_xx = dy_xx
    dy_yy = dy_yy
    dy_zz = dy_zz
    dy_xy = dy_xy
    dy_yz = dy_yz
    dy_zx = dy_xz
    dz_xx = dz_xx
    dz_yy = dz_yy
    dz_zz = dz_zz
    dz_xy = dz_xy
    dz_yz = dz_yz
    dz_zx = dz_xz
    execute_on = 'timestep_end'
    outputs = 'exodus csv console'
  [../]
  [./H1133]
    type = AsymptoticExpansionHomogenizationElasticConstants
    base_name = zz
    row = xx
    column = zz
    dx_xx = dx_xx
    dx_yy = dx_yy
    dx_zz = dx_zz
    dx_xy = dx_xy
    dx_yz = dx_yz
    dx_zx = dx_xz
    dy_xx = dy_xx
    dy_yy = dy_yy
    dy_zz = dy_zz
    dy_xy = dy_xy
    dy_yz = dy_yz
    dy_zx = dy_xz
    dz_xx = dz_xx
    dz_yy = dz_yy
    dz_zz = dz_zz
    dz_xy = dz_xy
    dz_yz = dz_yz
    dz_zx = dz_xz
    execute_on = 'timestep_end'
    outputs = 'exodus csv console'
  [../]
  [./H2233]
    type = AsymptoticExpansionHomogenizationElasticConstants
    base_name = zz
    row = yy
    column = zz
    dx_xx = dx_xx
    dx_yy = dx_yy
    dx_zz = dx_zz
    dx_xy = dx_xy
    dx_yz = dx_yz
    dx_zx = dx_xz
    dy_xx = dy_xx
    dy_yy = dy_yy
    dy_zz = dy_zz
    dy_xy = dy_xy
    dy_yz = dy_yz
    dy_zx = dy_xz
    dz_xx = dz_xx
    dz_yy = dz_yy
    dz_zz = dz_zz
    dz_xy = dz_xy
    dz_yz = dz_yz
    dz_zx = dz_xz
    execute_on = 'timestep_end'
    outputs = 'exodus csv console'
  [../]
  [./H1212]
    type = AsymptoticExpansionHomogenizationElasticConstants
    base_name = xy
    row = xy
    column = xy
    dx_xx = dx_xx
    dx_yy = dx_yy
    dx_zz = dx_zz
    dx_xy = dx_xy
    dx_yz = dx_yz
    dx_zx = dx_xz
    dy_xx = dy_xx
    dy_yy = dy_yy
    dy_zz = dy_zz
    dy_xy = dy_xy
    dy_yz = dy_yz
    dy_zx = dy_xz
    dz_xx = dz_xx
    dz_yy = dz_yy
    dz_zz = dz_zz
    dz_xy = dz_xy
    dz_yz = dz_yz
    dz_zx = dz_xz
    execute_on = 'timestep_end'
    outputs = 'exodus csv console'
  [../]
  [./H1313]
    type = AsymptoticExpansionHomogenizationElasticConstants
    base_name = xz
    row = xz
    column = xz
    dx_xx = dx_xx
    dx_yy = dx_yy
    dx_zz = dx_zz
    dx_xy = dx_xy
    dx_yz = dx_yz
    dx_zx = dx_xz
    dy_xx = dy_xx
    dy_yy = dy_yy
    dy_zz = dy_zz
    dy_xy = dy_xy
    dy_yz = dy_yz
    dy_zx = dy_xz
    dz_xx = dz_xx
    dz_yy = dz_yy
    dz_zz = dz_zz
    dz_xy = dz_xy
    dz_yz = dz_yz
    dz_zx = dz_xz
    execute_on = 'timestep_end'
    outputs = 'exodus csv console'
  [../]
  [./H2323]
    type = AsymptoticExpansionHomogenizationElasticConstants
    base_name = yz
    row = yz
    column = yz
    dx_xx = dx_xx
    dx_yy = dx_yy
    dx_zz = dx_zz
    dx_xy = dx_xy
    dx_yz = dx_yz
    dx_zx = dx_xz
    dy_xx = dy_xx
    dy_yy = dy_yy
    dy_zz = dy_zz
    dy_xy = dy_xy
    dy_yz = dy_yz
    dy_zx = dy_xz
    dz_xx = dz_xx
    dz_yy = dz_yy
    dz_zz = dz_zz
    dz_xy = dz_xy
    dz_yz = dz_yz
    dz_zx = dz_xz
    execute_on = 'timestep_end'
    outputs = 'exodus csv console'
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = false
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart -pc_hypre_boomeramg_strong_threshold'
  petsc_options_value = 'hypre boomeramg 31 0.7'
  l_tol = 1.0e-4
  l_max_its = 30
  nl_max_its = 40
  nl_rel_tol = 1.0e-7
  start_time = 0.0

  num_steps = 3
  end_time = 1

  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1
    growth_factor = 1.2
    cutback_factor = 0.8
    optimal_iterations = 8
  [../]
[]

[Outputs]
  execute_on = 'timestep_end'
  exodus = true
  csv = true
  checkpoint = true
[]
