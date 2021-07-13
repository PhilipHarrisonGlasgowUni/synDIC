# synDIC
The idea behind these codes is to evaluate the viability of tracking displacements using any image (rather than a speckle-pattern) using DIC. The original motivation behind the development of these codes was to monitor the strains occurring in historic tapestries (due to self-weight and changes in humidity). 

To do this we synthetically deform images using FE-generated strain fields (based on the images-features), then use these deformed-images to assess the accuracy of DIC measurements in tracking displacements and strains, by comparing the latter with the FEA predicted displacements and strains.

The only required commercial resource is MatLab. An open source linear FEA code has been implmented and works with open source DIC codes including Ncorr (a free MatLab DIC code). Other options include use of Abaqus for FEA and VIC-2D for the DIC. 

A tutorial on how to use the codes is included in the reporsitory and a case study demonstrating the use of the codes is found in the final year project report by Alifah Mohd Faridz also included in the reporsitory.
