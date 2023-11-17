[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 885
  ny = 885 
  nz = 0
  xmax = ${GlobalParams/L}
  ymax = ${GlobalParams/L}
  zmax = 0
  elem_type = QUAD4
[]

[GlobalParams]
  op_num = 10
  var_name_base = etam
  int_width = 60
  L = 2.6587e4

  use_kdtree = true

  numfacebub = 150 
  facebubspac = 400 
  faceradius = 150
  
  numcornerbub = 1
  cornerbubspac = 10
  cornerradius = 1e-3

  faceradius_variation = 0
  faceradius_variation_type = normal
  cornerradius_variation = 0
  cornerradius_variation_type = normal

  invalue = 1
  outvalue = 0
  numtries = 1e8
[]

[Variables]
  [./PolycrystalVariables]
  [../]
  [./dx_xx]
  [../]
  [./dx_yy]
  [../]
  [./dx_xy]
  [../]
  [./dy_xx]
  [../]
  [./dy_yy]
  [../]
  [./dy_xy]
  [../]
[]

[AuxVariables]
  [./bnds]
    order = FIRST
    family = LAGRANGE
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
    [./PolycrystalVoronoiCoupledVoidIC]
      v = etab0
      polycrystal_ic_uo = voronoi_ic_uo
    [../]
  [../]
  [./bubble_IC]
    type = PolycrystalVoronoiIntergranularVoidIC
    variable = etab0
    polycrystal_ic_uo = voronoi_ic_uo
  [../]
[]

[UserObjects]
  [./voronoi_ic_uo]
    type = PolycrystalVoronoi
    coloring_algorithm = jp
    rand_seed = 12345
    file_name = 'input_mps_1micron-grains_coordinates_2D.dat'
  [../]
  [./euler_angle_file]
    type = EulerAngleFileReader
    file_name =  input_36grains_texture_2D.tex
  [../]
  [./grain_tracker]
    type = GrainTrackerElasticity
    threshold = 0.2
    compute_var_to_feature_map = true
    execute_on = 'initial timestep_begin timestep_end'
    flood_entity_type = ELEMENTAL
    fill_method = symmetric9
    # C_ijkl = '146.5   83.3   83.3  146.5   83.3  146.5   31.6   31.6   31.6' # isotropic/ polycrystal (PC)
    C_ijkl = '140.2   89.6   89.6  140.2   89.6  140.2   38.7   38.7   38.7' # single crystal (SC)
    euler_angle_provider = euler_angle_file
    outputs = csv
  [../]
[]

[BCs]
  [./Periodic]
    [./All]
      auto_direction = 'x y'
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
  [./dy_xy_top_bottom]
    type = DirichletBC
    variable = dy_xy
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
  [./dx_xy_left_right]
    type = DirichletBC
    variable = dx_xy
    boundary = 'left right'
    value = 0.0
  [../]
[]

[Kernels]
  [./ACb0_bulk]
    type = ACGrGrMulti
    variable = etab0
    mob_name = L
    v = 'etam0 etam1 etam2 etam3 etam4 etam5 etam6 etam7 etam8 etam9 '
    gamma_names = ' gmb  gmb  gmb  gmb  gmb  gmb  gmb  gmb  gmb  gmb  '
  [../]
  [./ACm0_bulk]
    type = ACGrGrMulti
    variable = etam0
    mob_name = L
    v = 'etab0 etam1 etam2 etam3 etam4 etam5 etam6 etam7 etam8 etam9 '
    gamma_names = 'gmb  gmm  gmm  gmm  gmm  gmm  gmm  gmm  gmm  gmm  '
  [../]
  [./ACm1_bulk]
    type = ACGrGrMulti
    variable = etam1
    mob_name = L
    v = 'etab0 etam0 etam2 etam3 etam4 etam5 etam6 etam7 etam8 etam9 '
    gamma_names = 'gmb  gmm  gmm  gmm  gmm  gmm  gmm  gmm  gmm  gmm  '
  [../]
  [./ACm2_bulk]
    type = ACGrGrMulti
    variable = etam2
    mob_name = L
    v = 'etab0 etam0 etam1 etam3 etam4 etam5 etam6 etam7 etam8 etam9 '
    gamma_names = 'gmb  gmm  gmm  gmm  gmm  gmm  gmm  gmm  gmm  gmm  '
  [../]
  [./ACm3_bulk]
    type = ACGrGrMulti
    variable = etam3
    mob_name = L
    v = 'etab0 etam0 etam1 etam2 etam4 etam5 etam6 etam7 etam8 etam9 '
    gamma_names = 'gmb  gmm  gmm  gmm  gmm  gmm  gmm  gmm  gmm  gmm  '
  [../]
  [./ACm4_bulk]
    type = ACGrGrMulti
    variable = etam4
    mob_name = L
    v = 'etab0 etam0 etam1 etam2 etam3 etam5 etam6 etam7 etam8 etam9 '
    gamma_names = 'gmb  gmm  gmm  gmm  gmm  gmm  gmm  gmm  gmm  gmm  '
  [../]
  [./ACm5_bulk]
    type = ACGrGrMulti
    variable = etam5
    mob_name = L
    v = 'etab0 etam0 etam1 etam2 etam3 etam4 etam6 etam7 etam8 etam9 '
    gamma_names = 'gmb  gmm  gmm  gmm  gmm  gmm  gmm  gmm  gmm  gmm  '
  [../]
  [./ACm6_bulk]
    type = ACGrGrMulti
    variable = etam6
    mob_name = L
    v = 'etab0 etam0 etam1 etam2 etam3 etam4 etam5 etam7 etam8 etam9 '
    gamma_names = 'gmb  gmm  gmm  gmm  gmm  gmm  gmm  gmm  gmm  gmm  '
  [../]
  [./ACm7_bulk]
    type = ACGrGrMulti
    variable = etam7
    mob_name = L
    v = 'etab0 etam0 etam1 etam2 etam3 etam4 etam5 etam6 etam8 etam9 '
    gamma_names = 'gmb  gmm  gmm  gmm  gmm  gmm  gmm  gmm  gmm  gmm  '
  [../]
  [./ACm8_bulk]
    type = ACGrGrMulti
    variable = etam8
    mob_name = L
    v = 'etab0 etam0 etam1 etam2 etam3 etam4 etam5 etam6 etam7 etam9 '
    gamma_names = 'gmb  gmm  gmm  gmm  gmm  gmm  gmm  gmm  gmm  gmm  '
  [../]
  [./ACm9_bulk]
    type = ACGrGrMulti
    variable = etam9
    mob_name = L
    v = 'etab0 etam0 etam1 etam2 etam3 etam4 etam5 etam6 etam7 etam8 '
    gamma_names = 'gmb  gmm  gmm  gmm  gmm  gmm  gmm  gmm  gmm  gmm  '
  [../]
  
  [./ACb_sw]
    type = ACSwitching
    variable = etab0
    mob_name = L
    Fj_names = 'f0b      f0m'
    hj_names = 'hb       hm'
    coupled_variables = 'etam0 etam1 etam2 etam3 etam4 etam5 etam6 etam7 etam8 etam9 '
  [../]
  [./ACm0_sw]
    type = ACSwitching
    variable = etam0
    mob_name = L
    Fj_names = 'f0b      f0m'
    hj_names = 'hb       hm'
    coupled_variables = 'etab0 etam1 etam2 etam3 etam4 etam5 etam6 etam7 etam8 etam9 '
  [../]
  [./ACm1_sw]
    type = ACSwitching
    variable = etam1
    mob_name = L
    Fj_names = 'f0b      f0m'
    hj_names = 'hb       hm'
    coupled_variables = 'etab0 etam0 etam2 etam3 etam4 etam5 etam6 etam7 etam8 etam9 '
  [../]
  [./ACm2_sw]
    type = ACSwitching
    variable = etam2
    mob_name = L
    Fj_names = 'f0b      f0m'
    hj_names = 'hb       hm'
    coupled_variables = 'etab0 etam0 etam1 etam3 etam4 etam5 etam6 etam7 etam8 etam9 '
  [../]
  [./ACm3_sw]
    type = ACSwitching
    variable = etam3
    mob_name = L
    Fj_names = 'f0b      f0m'
    hj_names = 'hb       hm'
    coupled_variables = 'etab0 etam0 etam1 etam2 etam4 etam5 etam6 etam7 etam8 etam9 '
  [../]
  [./ACm4_sw]
    type = ACSwitching
    variable = etam4
    mob_name = L
    Fj_names = 'f0b      f0m'
    hj_names = 'hb       hm'
    coupled_variables = 'etab0 etam0 etam1 etam2 etam3 etam5 etam6 etam7 etam8 etam9 '
  [../]
  [./ACm5_sw]
    type = ACSwitching
    variable = etam5
    mob_name = L
    Fj_names = 'f0b      f0m'
    hj_names = 'hb       hm'
    coupled_variables = 'etab0 etam0 etam1 etam2 etam3 etam4 etam6 etam7 etam8 etam9 '
  [../]
  [./ACm6_sw]
    type = ACSwitching
    variable = etam6
    mob_name = L
    Fj_names = 'f0b      f0m'
    hj_names = 'hb       hm'
    coupled_variables = 'etab0 etam0 etam1 etam2 etam3 etam4 etam5 etam7 etam8 etam9 '
  [../]
  [./ACm7_sw]
    type = ACSwitching
    variable = etam7
    mob_name = L
    Fj_names = 'f0b      f0m'
    hj_names = 'hb       hm'
    coupled_variables = 'etab0 etam0 etam1 etam2 etam3 etam4 etam5 etam6 etam8 etam9 '
  [../]
  [./ACm8_sw]
    type = ACSwitching
    variable = etam8
    mob_name = L
    Fj_names = 'f0b      f0m'
    hj_names = 'hb       hm'
    coupled_variables = 'etab0 etam0 etam1 etam2 etam3 etam4 etam5 etam6 etam7 etam9 '
  [../]
  [./ACm9_sw]
    type = ACSwitching
    variable = etam9
    mob_name = L
    Fj_names = 'f0b      f0m'
    hj_names = 'hb       hm'
    coupled_variables = 'etab0 etam0 etam1 etam2 etam3 etam4 etam5 etam6 etam7 etam8 '
  [../]
    
  [./ACb_int]
    type = ACInterface
    variable = etab0
    mob_name = L
    kappa_name = kappa
  [../]
  [./ACm0_int]
    type = ACInterface
    variable = etam0
    mob_name = L
    kappa_name = kappa
  [../]
  [./ACm1_int]
    type = ACInterface
    variable = etam1
    mob_name = L
    kappa_name = kappa
  [../]
  [./ACm2_int]
    type = ACInterface
    variable = etam2
    mob_name = L
    kappa_name = kappa
  [../]
  [./ACm3_int]
    type = ACInterface
    variable = etam3
    mob_name = L
    kappa_name = kappa
  [../]
  [./ACm4_int]
    type = ACInterface
    variable = etam4
    mob_name = L
    kappa_name = kappa
  [../]
  [./ACm5_int]
    type = ACInterface
    variable = etam5
    mob_name = L
    kappa_name = kappa
  [../]
  [./ACm6_int]
    type = ACInterface
    variable = etam6
    mob_name = L
    kappa_name = kappa
  [../]
  [./ACm7_int]
    type = ACInterface
    variable = etam7
    mob_name = L
    kappa_name = kappa
  [../]
  [./ACm8_int]
    type = ACInterface
    variable = etam8
    mob_name = L
    kappa_name = kappa
  [../]
  [./ACm9_int]
    type = ACInterface
    variable = etam9
    mob_name = L
    kappa_name = kappa
  [../]
  
  [./etab_dot]
    type = TimeDerivative
    variable = etab0
  [../]
  [./etam0_dot]
    type = TimeDerivative
    variable = etam0
  [../]
  [./etam1_dot]
    type = TimeDerivative
    variable = etam1
  [../]
  [./etam2_dot]
    type = TimeDerivative
    variable = etam2
  [../]
  [./etam3_dot]
    type = TimeDerivative
    variable = etam3
  [../]
  [./etam4_dot]
    type = TimeDerivative
    variable = etam4
  [../]
  [./etam5_dot]
    type = TimeDerivative
    variable = etam5
  [../]
  [./etam6_dot]
    type = TimeDerivative
    variable = etam6
  [../]
  [./etam7_dot]
    type = TimeDerivative
    variable = etam7
  [../]
  [./etam8_dot]
    type = TimeDerivative
    variable = etam8
  [../]
  [./etam9_dot]
    type = TimeDerivative
    variable = etam9
  [../]

  [./div_x_xx]
    type = StressDivergenceTensors
    component = 0
    variable = dx_xx
    displacements = 'dx_xx dy_xx'
    use_displaced_mesh = false
    base_name = xx
  [../]
  [./div_y_xx]
    type = StressDivergenceTensors
    component = 1
    variable = dy_xx
    displacements = 'dx_xx dy_xx'
    use_displaced_mesh = false
    base_name = xx
  [../]
  [./div_x_yy]
    type = StressDivergenceTensors
    component = 0
    variable = dx_yy
    displacements = 'dx_yy dy_yy'
    use_displaced_mesh = false
    base_name = yy
  [../]
  [./div_y_yy]
    type = StressDivergenceTensors
    component = 1
    variable = dy_yy
    displacements = 'dx_yy dy_yy'
    use_displaced_mesh = false
    base_name = yy
  [../]
  [./div_x_xy]
    type = StressDivergenceTensors
    component = 0
    variable = dx_xy
    displacements = 'dx_xy dy_xy'
    use_displaced_mesh = false
    base_name = xy
  [../]
  [./div_y_xy]
    type = StressDivergenceTensors
    component = 1
    variable = dy_xy
    displacements = 'dx_xy dy_xy'
    use_displaced_mesh = false
    base_name = xy
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
[]

[Materials]
  [./constants_new_U10Mo]
    type = GenericConstantMaterial
    prop_names =  'kappa        L        f0b     f0m    mu        gmb 	     gmm  '    # length scale = 30 nm, energy scale = 64e9 J/m3
    prop_values = '1.0547       100       0      0      0.0023    0.5522     1.5   '
  [../]

  [./hb]
    type = SwitchingFunctionMultiPhaseMaterial
    h_name = hb
    all_etas = 'etab0 etam0 etam1 etam2 etam3 etam4 etam5 etam6 etam7 etam8 etam9'
    phase_etas = 'etab0'
  [../]
  [./hm]
    type = SwitchingFunctionMultiPhaseMaterial
    h_name = hm
    all_etas = 'etab0 etam0 etam1 etam2 etam3 etam4 etam5 etam6 etam7 etam8 etam9'
    phase_etas = 'etam0 etam1 etam2 etam3 etam4 etam5 etam6 etam7 etam8 etam9'
  [../]

  [./PolyGrElasticityTensor]
    type = ComputePolycrystalElasticityTensor
    block = 0
    base_name = Cijkl_polyGr
    grain_tracker = grain_tracker
  [../]
  [./elasticity_tensor_bubble]
    type = ComputeElasticityTensor
    block = 0
    base_name = Cijkl_bub
    C_ijkl = '1e-3    1e-3  1e-3   1e-3   1e-3   1e-3   1e-3    1e-3   1e-3' # void
    fill_method = symmetric9
  [../]
  [./elasticity_tensor_polyGr_bub_composite]
    type = CompositeElasticityTensor
    block = 0
    tensors = 'Cijkl_polyGr Cijkl_bub'
    weights = 'hm            hb'
    coupled_variables = 'etab0 etam0 etam1 etam2 etam3 etam4 etam5 etam6 etam7 etam8 etam9'
  [../]

  [./elastic_stress_xx]
    type = ComputeLinearElasticStress
    base_name = xx
  [../]
  [./elastic_stress_yy]
    type = ComputeLinearElasticStress
    base_name = yy
  [../]
  [./elastic_stress_xy]
    type = ComputeLinearElasticStress
    base_name = xy
  [../]

  [./strain_xx]
    type = ComputeSmallStrain
    displacements = 'dx_xx dy_xx'
    base_name = xx
  [../]
  [./strain_yy]
    type = ComputeSmallStrain
    displacements = 'dx_yy dy_yy'
    base_name = yy
  [../]
  [./strain_xy]
    type = ComputeSmallStrain
    displacements = 'dx_xy dy_xy'
    base_name = xy
  [../]

  [./ElasticityTensor_polyGr_bub_composite_xx]
    type = CompositeElasticityTensor
    block = 0
    tensors = 'Cijkl_polyGr Cijkl_bub'
    weights = 'hm            hb'
    coupled_variables = 'etab0 etam0 etam1 etam2 etam3 etam4 etam5 etam6 etam7 etam8 etam9'
    base_name = xx
  [../]
  [./ElasticityTensor_polyGr_bub_composite_xy]
    type = CompositeElasticityTensor
    block = 0
    tensors = 'Cijkl_polyGr Cijkl_bub'
    weights = 'hm            hb'
    coupled_variables = 'etab0 etam0 etam1 etam2 etam3 etam4 etam5 etam6 etam7 etam8 etam9'
    base_name = xy
  [../]
  [./ElasticityTensor_polyGr_bub_composite_yy]
    type = CompositeElasticityTensor
    block = 0
    tensors = 'Cijkl_polyGr Cijkl_bub'
    weights = 'hm            hb'
    coupled_variables = 'etab0 etam0 etam1 etam2 etam3 etam4 etam5 etam6 etam7 etam8 etam9'
    base_name = yy
  [../]
[]

[AuxKernels]
  [./BndsCalc]
    type = BndsCalcAux
    variable = bnds
    execute_on = 'timestep_end'
    v = 'etam0 etam1 etam2 etam3 etam4 etam5 etam6 etam7 etam8 etam9'
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
  [numbub]
    type = FeatureFloodCount
    variable = etab0
  []

  [./H1111]
    type = AsymptoticExpansionHomogenizationElasticConstants
    base_name = xx
    row = xx
    column = xx
    dx_xx = dx_xx
    dy_xx = dy_xx
    dx_yy = dx_yy
    dy_yy = dy_yy
    dx_xy = dx_xy
    dy_xy = dy_xy
    execute_on = 'timestep_end'
    outputs = 'exodus csv console'
  [../]
  [./H1122]
    type = AsymptoticExpansionHomogenizationElasticConstants
    base_name = xx
    row = xx
    column = yy
    dx_xx = dx_xx
    dy_xx = dy_xx
    dx_yy = dx_yy
    dy_yy = dy_yy
    dx_xy = dx_xy
    dy_xy = dy_xy
    execute_on = 'timestep_end'
    outputs = 'exodus csv console'
  [../]
  [./H2222]
    type = AsymptoticExpansionHomogenizationElasticConstants
    base_name = xx
    row = yy
    column = yy
    dx_xx = dx_xx
    dy_xx = dy_xx
    dx_yy = dx_yy
    dy_yy = dy_yy
    dx_xy = dx_xy
    dy_xy = dy_xy
    execute_on = 'timestep_end'
    outputs = 'exodus csv console'
  [../]
  [./H2211]
    type = AsymptoticExpansionHomogenizationElasticConstants
    base_name = xy
    row = yy
    column = xx
    dx_xx = dx_xx
    dy_xx = dy_xx
    dx_yy = dx_yy
    dy_yy = dy_yy
    dx_xy = dx_xy
    dy_xy = dy_xy
    execute_on = 'initial timestep_end'
    outputs = 'exodus csv console'
  [../]
  [./H1212]
    type = AsymptoticExpansionHomogenizationElasticConstants
    base_name = xx
    row = xy
    column = xy
    dx_xx = dx_xx
    dy_xx = dy_xx
    dx_yy = dx_yy
    dy_yy = dy_yy
    dx_xy = dx_xy
    dy_xy = dy_xy
    execute_on = 'timestep_end'
    outputs = 'exodus csv console'
  [../]

  [./feature_counter]
    type = FeatureFloodCount
    variable = etab0
    threshold = 0.5
    compute_var_to_feature_map = true
    execute_on = 'timestep_end'
  [../]
  [./Volume]
    type = VolumePostprocessor
    execute_on = 'timestep_end'
  [../]
  [./volume_fraction]
    type = FeatureVolumeFraction
    mesh_volume = Volume
    feature_volumes = feature_volumes
    execute_on = 'timestep_end'
  [../]
[]

[VectorPostprocessors]
  [./feature_volumes]
    type = FeatureVolumeVectorPostprocessor
    flood_counter = feature_counter
    execute_on = 'timestep_end'
    single_feature_per_element = true
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

  end_time = 10

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
