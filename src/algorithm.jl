# Defines how various different algorithms are implemented
using FFAST # for mass absorption coefficienct
using BoteSalvatICX # For ionization crosssections

const shellnames = ( "K", "L1", "L2", "L3", "M1", "M2", "M3", "M4", "M5",
    "N1", "N2", "N3", "N4", "N5", "N6", "N7", "O1", "O2", "O3",
    "O4", "O5", "O6", "O7", "O8", "O9", "P1", "P2", "P3", "P4", "P5",
    "P6", "P7", "P8", "P9", "P10", "P11" )
"""
    shellIndex(shell::AbstractString)

Maps shell names ("K","L1", ...,"P11") to an integer index ("K"==1,"L1"==2, etc).
"""
shellIndex(shell::AbstractString) =
    findfirst(name->shell==name, shellnames)

"""
    massAbsorptionCoefficient(z::Int, energy::Float64)::Float64

The mass absorption coefficient for the specified energy X-ray (in eV) in the specified element (z=> atomic number).
"""
massAbsorptionCoefficient(z::Int, energy::Float64)::Float64 =
    ffastMACpe(z,energy)

"""
    shellEnergy(z::Int, sh::Int)::Float64

The minimum energy (in eV) necessary to ionize the specified shell in the specified atom.
"""
shellEnergy(z::Int, sh::Int)::Float64 =
    ffastEdgeEnergy(z,sh)

"""
    elementRange() = 1:92

The range of atomic numbers for which there is a complete set of energy, weight, MAC, ... data
"""
elementRange() =
    ffastElementRange()

"""
    shellindexes(z::Int)

The shells occupied in a neutral, ground state atom of the specified atomic number.
"""
shellindexes(z::Int) =
    ffastEdges(z)

"""
    characteristicXRayEnergy(z::Int, inner::Int, outer::Int)::Float64

The energy (in eV) of the transition by specified inner and outer shell index.
"""
characteristicXRayEnergy(z::Int, inner::Int, outer::Int)::Float64 =
    ffastEdgeEnergy(z,inner)-ffastEdgeEnergy(z,outer)


"""
    ionizationCrossSection(z::Int, shell::Int, energy::AbstractFloat)

Computes the absolute ionization crosssection (in cm2) for the specified element, shell and
electon energy (in eV).
"""
ionizationCrossSection(z::Int, shell::Int, energy::AbstractFloat) =
    boteSalvatAvailable(z, shell) ? boteSalvatICX(z, shell, energy, shellEnergy(z,shell)) : 0.0

jumpRatio(z::Int, shell::Int) =
    ffastJumpRatio(z,shell)

include("strength.jl")

"""
    characteristicXRayEnergy(z::Int, inner::Int, outer::Int)::Float64

The transition strength of the transition by specified inner and outer shell index.
"""
characteristicXRayStrength(z::Int, inner::Int, outer::Int)::Float64 =
    nexlWeights(z,inner,outer)

"""
    characteristicXRayAvailable(z::Int, inner::Int, outer::Int)::Float64

Is the weight associated with this transition greater than zero.
"""
charactericXRayAvailable(z::Int, inner::Int, outer::Int)::Bool =
    nexlIsAvailable(z,inner,outer)


"""
    approxKShellFluorescenceYield(z::Int)

An approximate expression for the K-shell fluorescence yield due to
E.H.S Burhop, J. Phys. Radium, 16, 625 (1965)
"""
function approxKShellFluorescenceYield(z::Int)
    d = -0.044 + 0.0346z - 1.35e-6z^3
    return d^4/(1.0+d^4)
end
