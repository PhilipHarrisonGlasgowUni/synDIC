# synDIC
The idea behind these codes is to evaluate the viability of tracking displacements using any image (rather than a speckle-pattern) using DIC. The original motivation behind the development was to monitor the strains occurring in historic tapestries (due to self-weight and changes in humidity) as part of a Leverhulme Trust funded project collaborating with prof Frances Lennard:

To do this we synthetically deform images using FE-generated strain fields (based on the images-features), then use these deformed-images to assess the accuracy of DIC measurements in tracking displacements and strains, by comparing the latter with the FEA predicted displacements and strains.

The only required commercial resource is MatLab. An open source linear FEA code has been implmented and works with open source DIC codes including Ncorr (a free MatLab DIC code). Other options include use of Abaqus for FEA and VIC-2D for the DIC. 

Supporting documents in the repository include: 
(a) published paper by Alsayednoor et al. demonstrating the use of the early versions of the software: Alsayednoor, J., Harrison, P. , Dobbie, M., Costantini, R. and Lennard, F. (2019) Evaluating the use of digital image correlation for strain measurement in historic tapestries using representative deformation fields. Strain, 55(2), e12308. (doi: 10.1111/str.12308)
(b) a tutorial on how to use the most recent version of the codes and 
(c) a case study demonstrating the use of the codes (a final year project report by Alifah Mohd Faridz).
