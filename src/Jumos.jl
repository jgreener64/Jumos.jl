module Jumos
    using Reexport

    # This module define some basic types like 3D vectors
    # and store periodic table informations
    @reexport module SimulationBasics
        import Base: show

        type NotImplementedError <: Exception
            message::String
        end

        function show(io::IO, e::NotImplementedError)
            show(io, "Not implemented : $(e.message)")
        end

        export NotImplementedError

        include("vect3d.jl")
        include("Periodic.jl")
    end


    # This module allow reading and writing trajectories to files
    # A trajectory is built with a topology (atomic names and relations)
    # and some arrays of positions, velocities and forces.
    @reexport module Trajectories
        using Jumos: SimulationBasics

        include("Trajectories/Topology.jl")
        include("Trajectories/Trajectory.jl")
    end


    # This module offer functions to compute distances between atoms
    @reexport module Distances
        using Jumos: SimulationBasics, Trajectories

        include("Distances/Distances.jl")
    end


    # This module provide utilities for analysing trajectories, either
    # while runnning or using trajectories files
    @reexport module Analysis
        using Jumos: Trajectories, Distances

        include("Analysis/Histograms.jl")
    end

    @reexport module MolecularDynamics
        using Jumos: Trajectories, Distances, SimulationBasics

        include("Simulations/MolecularDynamics.jl")
    end


end # module
