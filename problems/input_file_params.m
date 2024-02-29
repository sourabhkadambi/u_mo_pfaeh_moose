%% Matlab scripts for calculating phase-field model input paramters for MOOSE
%
% References:
%
% [1] N. Moelans, B. Blanpain, P. Wollants, Quantitative analysis of grain boundary
%       properties in a generalized phase field model for grain growth in
%       anisotropic systems, Phys. Rev. B 78 (2008) 024113.
%
% [2] L. K. Aagesen, Y. Gao, D. Schwen, K. Ahmed, Grand-potential-based phasefield
%        model for multiple phases, grains, and chemical components, Physical
%        Review E 98 (2018) 023309.
%
%% Input parameters for intra and intergranular porosity

% clear

%%% Material properties
sigma_mimj = 0.5; % [J/m2] U-10Mo GB energy
sigma_mib0 = 1.5; % [J/m2] Pore surface energy
l_mib0 = 0.5e-9; % 45e-9; % [m] numerical GB width
% values for l_mib0 are 0.5e-9 (intra)  30e-9, 45e-9, 60e-9, 90e-9

%%% symmetric grain-pore interface
gamma_mib0 = 1.5;
g_of_gamma_mib0 = sqrt(2)/3;

kappa = (3/4)*sigma_mib0*l_mib0; % [J/m]
w = 6*sigma_mib0/l_mib0; % [J/m3]

%%% non-dimensionalization of parameters for MOOSE input file
energy_scale = 64e9; % [J/m3]
length_scale = 1e-9; % [m]

w_ndim = w/energy_scale;
kappa_ndim = kappa/(length_scale^2*energy_scale);
l_mib0_ndim = l_mib0/length_scale;

fprintf('Non-dimensional parameters for MOOSE input file are: \n w = %f \n kappa = %f \n surface_width = %0.1f \n',w_ndim,kappa_ndim,l_mib0_ndim)
fprintf('Dimensional parameters for are: \n w = %0.1s (J/m3) \n kappa = %0.1s (J/m) \n surface_width = %0.1s (nm) \n',w,kappa,l_mib0/length_scale)

%% ... for verification of dehedral angle and GB width for intergranular porosity
%%% (to be run after prvious section)

%%% dihedral angle b/w pore surface and GB
phi = 2*acosd(sigma_mimj/(2*sigma_mib0)); 

%%% asymmetric grain-grain interface
g = g_of_gamma_mib0 * sigma_mimj/sigma_mib0; 
gamma_mimj = 1/(-5.288 * g^8 - 0.09364 * g^6 + 9.965 * g^4 - 8.183 * g^2 + 2.007);
inv_gamma_mimj = 1/gamma_mimj;
y = inv_gamma_mimj;
f_int = 0.05676 * y^6 - 0.2924 * y^5 + 0.6367 * y^4 - 0.7749 * y^3 + 0.6107 * y^2 - 0.4324 * y + 0.2792;
l_mimj = sqrt(kappa/(w*f_int)); % expected GB width after interface equilibration
l_mimj_ndim = l_mimj/length_scale;

fprintf('The equilibrium interface properties are: \n dihedral angle = %0.1f degree \n GB width = %0.1f nm \n',phi,l_mimj_ndim)
