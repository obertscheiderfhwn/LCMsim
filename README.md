# LCMsim - A Julia module for filling simulations in Liquid Composite Moulding


# Summary
Resin Transfer Moulding (RTM) is a manufacturing process for producing thin-walled fiber reinforced polymer composites where dry fibers are placed inside a mould and resin is injected under pressure into the fibrous preform. In contrast to RTM, in Vaccum-Assisted Resin Infusion (VARI) vacuum pulls resin through the preform on a single-sided tool with vacuum bagging. During mold design for both RTM and VARI, filling simulations can study different manufacturing concepts (i.e. placement of inlet ports and vents) to guarantee complete filling of the part and avoid air entrapment where flow fronts converge. 

In all of the liquid composite manufacturing (LCM) technologies dry fiber preforms without resin are placed into a mold and the mold is closed. Resin then enters into the mold until the preform is fully wetted with resin. After the resin is cured the mold is opened and the part is extracted. In RTM resin is injected into a matched mold under pressure which gives excellent surface finishes on both sides and high fiber volume fractions (55-65 \%) can be obtained. In VARI, vacuum pulls liquid resin into a preform which lies on a single-sided tool normally used with a vacuum bagging which results on an excellent surface only on the tool side and only a lower fiber volume fraction (45-55 \%) can be obtained.

From a modeling point of view there are some differences between RTM and VARI. In RTM, the mold walls are considered rigid. In VARI, the prefom is placed on the mold and encapsulated with a plastic bag. Optionally, a flow distribution medium is placed on to top of the preform. The flexible plastic bag increases the cavity thickness as the fluid pressure increases inside the cavity during injection. The increased thickness results in an increased porosity and an increased permeability. For both RTM and VARI, the preform is stationary during injection.

During pre-processing the physical domain (i.e. the mold cavity) must be transfered to a numerical domain (i.e. the mesh), initial and boundary conditions must be assigned to the cells of the mesh. The simulation is started with a set of process parameters and a set of material parameters. The solver calculates how the values of the physical quantities in the cells change in the course of the filling. Different physical models of the filling can be implemented in the solver. The physical models have to describe all relevant issues of the filling process. During post-processing the resin flow front at different time instances must be visualized as contour plots.

Requried inputs for filling simulations are the mold cavity geometry, permeability, porosity and thickness values which describe the fibrous preform regions, flow properties like resin viscosity, initial cavity pressure and injection pressure. For flow through porous media, permeability and porosity must be determined before performing simulations.

The In-plane permeability for constant cavity height is characterized experimentally from linear or radial flow experiments. During the actual flow experiment, the flow front location is tracked over time and the entries of the in-plane permeability tensor are finally computed according to specifically developed mathematical algorithms. In order to find the dependence of the permeability from the porosity (e.g. with the Carman-Kozeny relation), measurements with different porosity levels are performed. If the cavity heigh changes in VARI, also the porosity and consequently the permeability change. The through-the-thickness permeablitiy is only important for VARI with flow distribution medium and not considered here.

For constant cavity height, the porosity can be calculated from cavity thickness $t$, mass density $\rho_{f}$ and areal weight $A_f$ of the preform material as $\varepsilon=t /(A_f/\rho_f)$. For variable cavity height, which is typical for VARI, porosity and permeability change. At least two pairs of (cavity thickness, compaction pressure) must be given, typically for compaction pressure equal to vacuum and for an intermediate value between vacuum and environmental pressure.

Initially the porous cavity is either evacuated or filled with air (air density according to cavity pressure) and pressurized resin is injected into the fibrous preform or vacuum pulls resin through the fibrous preform. 

A compressible continuity equation for the mixture density, an equation-of-state which describes the pressure build-up with increasing mixture density and a momentum equation with dynamic viscosity of the resin in the Darcy term describe the fluid flow. For tracking the flow front a fluid fraction is calculated. 

In order to numerically solve the flow model with the equation of state from Figure, the computational domain (time and space) is discretized. Discretization of the governing equations on an unstructured mesh follows the ideas presented in .

The temporal domain (i.e. the simulation time) is split into a finite number of time steps where values for the physical quantities on the spatial domain are calculated in a time-marching manner. An explicit method with adaptive time stepping is used.

The spatial domain is defined on the cavity's mid-surface and described by a shell mesh in a format similar to the NASTRAN bulk data format . The mid-surface model can be curved and cells can have edges where more than two cells are connected to each other such as for handling T-junctions. The injection gate is part of the computational domain and injection pressure and resin fraction one is assigned to the cells belonging to this region. Vents can be specified optionally. If no vents are specified (similar to software myRTM) the simulated filling is not influenced as long as the flow front does not reach the fictitious vent position. Initial pressure is input, initial velocity is zero and initial resin fraction is zero in all cells except in those belonging to the injection gate. 

For discretizing the equations on the shell mesh of the part's mid-surface it is assumed that the geometry was locally flat there. The neighbouring cells are rotated about the common edges to lie in the plane of the considered cell and the velocity vectors of the neighbouring cells must be transformed into the same coordinate system.

The solver section (which is the relevant section if a different physical model is implemented) consists of a `for`-loop over all interior and wall cells inside a `while`-loop for the time evolution. For every interior and wall cell, the following steps are performed: First, the pressure and filling fraction gradients are evaluated. Second, the time evolution for new mass density, $x$- and $y$-velocities with the discretized continuum, $x$- and $y$-momentum equations in the cell coordinate systems is performed. Third, the pressure is evaluated according to the equation of state. Forth, the filling fraction is evaluated. Boundary conditions need not be updated since in the inlet and outlet cells pressure and mass density remain unchanged and the velocity values at the cell boundaries are evaluated in the numerical flux evaluation.



# Installation instructions

In order to use LCMsim for filling simulations perform the following steps:
- Download Julia from https://julialang.org/downloads/
- Install Julia and add an environment variable such that the Julia terminal can be started from the command line.
- Open a Julia terminal. 
- Change to package manager with `]` and `add Gtk GLMakie Makie NativeFileDialog Glob LinearAlgebra JLD2 GeometryBasics Random FileIO ProgressMeter` and return with the `backspace` key
- Download the current LCMsim release and extract.  
- For Windows operating system: Go to the folder with the LCMsim repository and double click on run_lcmsim_GUI.bat to start the GUI. For all operating systems: One has access to all functions through the Julia terminal. Open a Julia terminal, change to the directory with the LCMsim repository with `cd("path\\to\\working\\directory")` where the path can be absolute or relative and the levels are separated by `\\` and then start either the GUI with `include("lcmsim_GUI.jl")` or call all functions directly after executing `include("lcmsim.jl")`. 




# Example usage

## Mesh preparation

The new simulation tool does not include mesh generation. A 3-node triangular shell mesh with the pre-defined regions must be generated with a meshing tool before starting the filling simulation. The authors used Altair HyperWorks but also free software tools such as SALOME-MECA, GMSH or NETGEN can be used.

The shell mesh is created on the part's mid-surface. Mid-surface models are often available in composite manufacturing since computational stress analysis for thin-walled parts is performed on the part’s mid-surface too. 

The prepared shell mesh is imported via a text file where nodes, elements and element sets are described in a format similar to the NASTRAN bulk data format. Every line (except for the set definitions) contains ten fields of eight characters each. The first field contains the name of the item. The following paragraph shows an example for such a mesh file:
```
SET 1 = 1,2,3,4,5,6,
        7,8,9,10,11,12,
        13,14,15,16
GRID           1             0.0     0.0     0.0
GRID           3             0.3     0.3     0.0
GRID           4            -0.3     0.3     0.0
[...]
GRID         331        -2.115-2-.113318     0.0
GRID         332        -.117148.1562872     0.0
GRID         333        .2271322.1925105     0.0
CTRIA3         1       0      15       9      16
CTRIA3         2       0      16      10      19
CTRIA3         3       0      19      11      17
[...]
CTRIA3       586       0     243     302     332
CTRIA3       587       0     262     333     259
CTRIA3       588       0     232     259     333
```
Nodes are described by the keyword `GRID`, followed by a grid number, followed by a blank and three fields with the x, y and z coordinates of the node. The triangular cells are defined by the keyword `CTRIA3`, followed by a cell number, followed by a zero, followed by the three node numbers which constitute the cell. Nodes and cells need not be sorted nor starting with one. Cell sets are defined by the keyword `SET` followed by ` N = ` and the cell numbers separated by commas. Not more than 6 cell numbers per line. Then continue with the cell numbers in the line below after 8 blanks at the beginning of the line. Up to four sets can be defined. 

## Run simulation

RTMsim is executed with a well-defined list of parameters specified in an input text file, in the GUI or in the function call `rtmsim.rtmsim_rev1` in the terminal. The following figure shows the GUI with explanation of the parameters. The mesh file and all parameters must be specified in SI units.

<img src="figures/lcmsim_help.png">

The buttons in the first line on the LHS are used for mesh inspection, i.e. select a mesh file, plot the mesh with bounding box and plot the defined sets. The buttons in the second line on the LHS are used for starting and continuing a filling simulation. Every time the Start or Continue simulation button is pressed, a filling simulation is started. The simulated flow time `tmax`, the patch types and patch properties must be specified before. Every simulation calculates the flow front propagation during the next `tmax` seconds. If started with the Start simulation button, the cavity is empty initially. If started with the Continue simulation button, the results from the previous simulation are taken as initial condition. With the buttons in the third line one can select inlet ports with specified radius interactively in addition to using the defined sets, and start and continue such a simulation. The buttons in the forth line are used for post-processing, i.e. show filling and pressure distribution of a specified output file (final results are saved in results.jld2), plot filling at four equidistant time instances and filling at different time instances which are selected with a slider bar. The buttons in the line on the RHS are used to start the simulation with the parameters from the selected input file.

The complete set of input parameters can be accessed in the input file. The following paragraph shows an example for such an input file:
```
2    #i_model 
meshfiles\\mesh_permeameter5.bdf    #meshfilename 
160    #tmax
1.01325e5 1.225 1.4 0.071    #p_ref rho_ref gamma mu_resin_val 
1.91e5 1.0e5 1.2 960    #p_a_val p_init_val 
3.14e-3 0.604 163e-12 0.3086 1 0 0 0.604 0.6 0e5   #t_val porosity_val K_val alpha_val refdir1_val refdir2_val refdir3_val 
3.14e-3 0.7 3e-10 1 1 0 0 0.7 0e5    #t1_val porosity1_val K1_val alpha1_val refdir11_val refdir21_val refdir31_val 
3.14e-3 0.468 28.6e-12 0.122 1 0 0 0.468 0e5    #t2_val porosity2_val K2_val alpha2_val refdir12_val refdir22_val refdir32_val 
3.14e-3 0.7 3e-10 1 1 0 0 0.7 0e5    #t3_val porosity3_val K3_val alpha3_val refdir13_val refdir23_val refdir33_val 
3.14e-3 0.7 3e-10 1 1 0 0 0.7 0e5    #t4_val porosity4_val K4_val alpha4_val refdir14_val refdir24_val refdir34_val 
1 2 0 0    #patchtype1val patchtype2val patchtype3val patchtype4val 
0 results.jld2    #i_restart restartfilename 
0 0.01    #i_interactive r_p 
16    #n_pics
```

Parameter `i_model` specifies the flow model (`=2` for iso-thermal RTM, `=3` for iso-thermal VARI). `meshfilename` specifies the relative or absolute path to the used mesh file. `tmax` defines the simulated filling time. The parameters in the forth line define the adiabatic equation of state (reference pressure, reference density, adiabatic index) for air and the dynamic viscosity of the resin. The parameters in the fifth line define injection pressure and initial cavity pressure. The parameters in the lines 6 to 10 specify the preform parameters for the main preform and the optional four sets with different preform parameters. The sets for the patches are defined in the mesh file in ascending order. If less than four are defined, the patch types and the parameters for the additional ones are ignored. The preform parameters are preform thickness, porosity, permeability in first principal cell direction, permeablitiy fraction alpha specifies the permeablity in the second principal cell direction as alpha times permeablity in the first principal direction and the three components of a reference vector which is projected onto the cells to define the first principal cell direction. In line 11, the patch type of the four optional preform patches are specified. Numerical values 0, 1, 2 and 3 are allowed with the following interpretation:
- 0 ... the patch is ignored
- 1 ... the patch represents an inlet gate, where the specified injection pressure level applies
- 2 ... the patch specifies a preform region
- 3 ... the patch represents a vent, where the specified initial pressure level applies

Thus, the preform parameters of the four optional sets given in lines 7 to 10 are only used, if the corresponding patch type is specified with a value of 2. 
The parameters in line 12 are used for continuing a simulation for another `tmax` flow time, if `i_restart=1` with the data saved in file `restartfilename`. In line 13 the interactive mode can be turned on if `i_interactive=1`. At selected points in the preform (plot the mesh with second parameter `=2` and select with `p`+LMB), additional inlet port with radius `r_p` are assigned. If all patch types are `=0`, only the selected inlet ports are used. Otherwise the settings are cummulative. The last parameter `n_pics` determines the number of intermediate outputs.

CONTINUE HERE

A simulation with the parameters specified in an input file is executed either in the GUI by selecting the appropriate input file and afterwards running the simulation with this input file or from the Julia terminal with  the function `rtmsim.start_rtmsim("inputfiles\\input.txt")` where the input file name is the argument.

Alternatively to using the GUI, one has access to all the functions after compiling the Julia module. Popular functions are:
- `rtmsim.plot_mesh("meshfiles\\mesh_permeameter1_foursets.bdf",1)` for plotting the mesh defined in the bdf-file
- `rtmsim.plot_sets("meshfiles\\mesh_permeameter1_foursets.bdf")` for plotting the sets specified in the bdf-file
- `rtmsim.rtmsim_rev1(1,"meshfiles\\mesh_permeameter1_foursets.bdf",200, 101325,1.225,1.4,0.06, 1.35e5,1.00e5, 3e-3,0.7,3e-10,1,1,0,0, 3e-3,0.7,3e-10,1,1,0,0, 3e-3,0.7,3e-11,1,1,0,0, 3e-3,0.7,3e-11,1,1,0,0, 3e-3,0.7,3e-9,1,1,0,0, 1,0,0,0, 0,"results.jld2",0,0.01,16)` for starting a simulation with one pressure inlet port (sets 2, 3 and 4 are not used and consequently the preform parameters are ignored; since set 1 is a pressure inlet, also the parameters for set 1 are ignored and the only relevant parameter for the specified set is the pressure difference between injection and initial cavity pressure)
- `rtmsim.rtmsim_rev1(1,"meshfiles\\mesh_permeameter1_foursets.bdf",200, 101325,1.225,1.4,0.06, 1.35e5,1.00e5, 3e-3,0.7,3e-10,1,1,0,0, 3e-3,0.7,3e-10,1,1,0,0, 3e-3,0.7,3e-11,1,1,0,0, 3e-3,0.7,3e-11,1,1,0,0, 3e-3,0.7,3e-9,1,1,0,0, 1,2,2,2, 0,"results.jld2",0,0.01,16)` for starting a simulation with different patches and race tracking
- `rtmsim.rtmsim_rev1(1,"meshfiles\\mesh_permeameter1_foursets.bdf",200, 101325,1.225,1.4,0.06, 1.35e5,1.00e5, 3e-3,0.7,3e-10,1,1,0,0, 3e-3,0.7,3e-10,1,1,0,0, 3e-3,0.7,3e-11,1,1,0,0, 3e-3,0.7,3e-11,1,1,0,0, 3e-3,0.7,3e-9,1,1,0,0, 1,2,2,2, 1,"results.jld2",0,0.01,16)` for continuing the previous simulation
- `rtmsim.plot_mesh("meshfiles\\mesh_annulusfiller1.bdf",2)` for the manual selection of inlet ports with left mouse button click while key `p` is pressed
- `rtmsim.rtmsim_rev1(1,"meshfiles\\mesh_annulusfiller1.bdf",200, 0.35e5,1.205,1.4,0.06, 0.35e5,0.00e5, 3e-3,0.7,3e-10,1,1,0,0, 3e-3,0.7,3e-10,1,1,0,0, 3e-3,0.7,3e-10,1,1,0,0, 3e-3,0.7,3e-10,1,1,0,0, 3e-3,0.7,3e-10,1,1,0,0, 0,0,0,0, 0,"results.jld2",1,0.01,16)` for starting only with the interactively selected inlet ports
- `rtmsim.plot_results("results.jld2")` for plotting the final filling and pressure contours
- `rtmsim.plot_overview(-1,-1)` for plotting the filling contours at four equidistant time instances
- `rtmsim.plot_filling(-1,-1)` for plotting the filling at different time instances selected with a slider bar
- `rtmsim.start_rtmsim("inputfiles\\input.txt")` for starting a simulation with the parameters specified in the text file input.txt

# Validation and verification cases

Three different test cases are available, successfully validating the Julia implementation of the RTM filling model:
1. Validation of the software tool for radial flow with isotropic in-plane permeablity: The simulated flow front position after 200 s is compared with the calculated flow front position from literature.  
2. Verification of the software tool for radial flow with tilted orthotropic in-plane permeablity: The simulated tilted elliptical flow front is analysed and the calculated orthotropic permeablity is compared with the simulation input.
3. Comparison of the simulated flow front position for a complex annulus filler-like part with the simulated flow front position from Ansys Fluent and comparison of the simulated filling pattern with results from a myRTM simulation.

The validation and verification cases can be executed in the GUI and from the Julia terminal. The input files for the validation cases are `input_case1_coarsemesh.txt`, `input_case1_finemesh.txt`, `input_case2_coarsemesh.txt`, `input_case2_finemesh.txt`, `input_case3_coarsemesh.txt`, `input_case3_finemesh.txt`. The input file names are saved in directory `inputfiles`. The filling overview is created with the button `Plot overview` in the GUI or with `rtmsim.plot_overview(-1,-1)` from the Julia terminal. 

The following passages show and explain the simulation results (after rotating the views with LMB) for the test cases.

Results for coarse and fine mesh of case 1 (Preform size 0.6 x 0.6 x 0.003 m^3, central injection gate with 0.02 m diameter, 35000 Pa injection pressure, dynamic viscosity 0.06 Pas, porosity 0.7, isotropic permeablity 3e-10 m^2):
<img src="figures/validation_case1a.png"><br>
<img src="figures/validation_case1b.png"><br>
According to an analytical estimation, the flow front after 50, 100, 150 and 200 s is a circle with radius 0.114, 0.150, 0.178 and 0.200 m. The values for the fine mesh agree well with the results from the analytical formula. The values for the coarse mesh show an error of <15% which decreases significantly in the course of time but the shape is no smooth circle.

Results for coarse and fine mesh of case 2 (Preform size 0.6 x 0.6 x 0.003 m^3, central injection gate with 0.02 m diameter, 35000 Pa injection pressure, dynamic viscosity 0.06 Pas, porosity 0.70, permeability 3.0e-10 m^2 in first principal direction 30° to the horizontal and permeability 1.5e-10 m^2 in second principal direction):
<img src="figures/validation_case2a.png"><br>
<img src="figures/validation_case2b.png"><br>
Analyzing the flow front after 200 s, the orthotropic permeability is described by 2.97e-10 m^2, 1.45e-10 m^2 and angle 35° for the fine mesh and 2.48e-10 m^2, 1.18e-10 m^2 and 35° for the coarse mesh. For the fine mesh (2198 cells for a domain with 600 × 600 mm), this reverse engineering shows very good agreement of the calculated orthotropic permeability  with the values used as simulation input. For the coarse mesh (588 cells) the agreement is still acceptable.

Results for coarse and fine mesh of case 3 (Bounding box of part is 0.4 x 0.15 x 0.1 m^3, part thickness is 0.003 m^3, injection gate at on end of the part, 35000 Pa injection pressure, dynamic viscosity 0.06 Pas, porosity 0.7, isotropic permeablity 3e-10 m^2):
<img src="figures/validation_case3a.png"><br>
<img src="figures/validation_case3b.png"><br>
If the position of inlet and outlet ports is investigated, simulations with a coarse mesh and consequently reduced computational time is sufficient since the flow front progagation is predicted properly. The actual filling time can only be predicted with a fine mesh. A mesh refinement study must be performed. With the coarse mesh it takes approximately 50 s longer to reach the same filling state. If the predicted filling with the fine mesh is considered correct, the error with the coarse mesh is approximately 20%. This is in good agreement with the results from case 1 where domain size, coarse and fine mesh are similar and the permeability and injection values are the same. 

# Use cases

The following three examples show typical use cases how RTMsim is used by engineers:

1. This examples shows how to start a simulation with the GUI. Select the mesh file `meshfiles\\mesh_permeameter1_foursets.bdf` and set all other parameters as shown:<br>
<img src="figures/example1a.png"><br>
First, inspect the mesh file and plot the pre-defined sets:<br>
<img src="figures/example1d.png"><br>
Set 1 is the pressure inlet, set 2 and set 3 are reinforcement patches with lower permeability and set 4 is a racetracking channel between the main preform and set 3 with same porosity but a factor 10 higher permeability than the main preform (racetracking with higher permeablity=higher flow speed takes place in thin regions between different patches or at the preform boundary). Then start the simulation and plot the filling overview after 200 s simulation time:<br>
<img src="figures/example1b.png"><br>
Continue the simulation for another 100 s simulation time and plot the filling overview:<br>
<img src="figures/example1c.png"><br>

2. This example shows how to use outlet ports. If outlet ports are defined, the outlet ports are connected to the catch pot (typically at ambient pressure or evacuated). If no outlet ports are defined, the hoses to the catch pot are clamped. The simulation is started with the following settings (mesh file is `mesh_annulusfiller1_inletandoutlet.bdf`):<br>
<img src="figures/example2a.png"><br>
The result plot shows the completely filled part with the grey inlet and outlet ports and the pressure contour:<br>
<img src="figures/example2b.png"><br>
The filling overview is:<br>
<img src="figures/example2c.png"><br>
The filling overview without pressure outlet (select Ignore radio button for the second set) shows only small differences at the very end of the filling:<br>
<img src="figures/example2e.png"><br>


3. This example shows a workflow for selecting the inlet ports interactively. First, select the mesh file `meshfiles\\mesh_annulusfiller1.bdf` and plot the mesh to see the bounding box size of the part:<br>
<img src="figures/example3a.png"><br>
Specify the inlet port radius and press the Select inlet port button:<br>
<img src="figures/example3b.png"><br>
Rotate the view with the nodes with LMB and select an inlet port location with key `p`+LMB. After selection the node is highlighted:<br>
<img src="figures/example3c.png"><br>
Selection of multiple nodes is possible. Then close the graphics window and start the simulation with the settings shown above by clicking the Start interactive button. All radio buttons show ignore if only the interactively selected inlet is used. In general, sets defining different preform properties or additional inlet ports or outlet regions can also be used in interactive mode. Plot the filling overview:<br>
<img src="figures/example3d.png"><br>
If cascade injection is planned (additional inlet port which is activated just after the flow front reached this location), select two inlet ports after clicking the button Select inlet port. The first one at the same location as before and the second one at the end of the current position of the flow front:<br>
<img src="figures/example3e.png"><br>
Close the graphics window and continue the simulation with the button Continue interactive. The filling and the final pressure contour are:<br>
<img src="figures/example3f.png"><br>
<img src="figures/example3g.png"><br>
Without cascade injection, the degree of filling is significantly lower as shown in the subsequent figure for a filling time of 400 s. <br>
<img src="figures/example3h.png"><br>

# Editorial
Suggestions for functionalities to be implemented and user feedback from case studies with this software are appreciated (e.g. via email to christof.obertscheider@fhwn.ac.at). 

If LCMsim is used for research or development, please use the following entry, shown in BiBTeX format:
```
@misc{RTMsim,
  author =       {Obertscheider, Christof and Fauster, Ewald},
  title =        {LCMsim - A Julia module for filling simulations in Liquid Composite Moulding},
  howpublished = {\url{https://github.com/obertscheiderfhwn/LCMsim}},
  year =         {2022}
}
```

