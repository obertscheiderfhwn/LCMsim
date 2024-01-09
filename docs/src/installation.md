# Installation 

The intended operating system for LCMsim is Windows. The software was extensively tested for Windows 10. In order to use LCMsim for filling simulations perform the following steps:
- Download Julia from https://julialang.org/downloads/
- Install Julia and add an environment variable such that the Julia terminal can be started from the command line.
- Open a Julia terminal. 
- Change to package manager with `]` and `add Gtk GLMakie Makie NativeFileDialog Glob LinearAlgebra JLD2 GeometryBasics Random FileIO ProgressMeter` and return with the `backspace` key
- Close the Julia terminal.
- Creat a working directory in the file explorer.
- Download the current LCMsim release and extract in the working directory.  
- Go to the working directory and double click on run_lcmsim_GUI.bat to start the GUI. 
- Alternatively, one has access to all functions through the Julia terminal. Open a Julia terminal, change to the directory with the LCMsim repository with `cd("path\\to\\working\\directory")` where the path can be absolute or relative and the levels are separated by `\\` and then start either the GUI with `include("lcmsim_GUI.jl")` or call all functions directly after executing `include("lcmsim.jl")`. 