# Image Validator
The purpose of this repository is to leverage Github Actions to carry out the validation of images that can be downloaded using 
the MATLAB Package Manager (MPM)

## Details

The github action that runs will:

1. Download a release of MATLAB with the entire product family supported for that release.
2. It will then use the MWSIGN executable to verify that the download of the product through MPM was correct and without any malicious entities.


## Requirements

1. MATLAB Package Manager
2. MWSIGN : Tool used to validate the downloaded artifact.


-------

Copyrights The Mathworks Inc. (c)

-------