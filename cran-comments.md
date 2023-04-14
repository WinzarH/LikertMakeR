
## Resubmission

There were no ERRORs or WARNINGs

##### results from R-hub

* Windows Server 2022, R-devel, 64 bit

   - OK

* checking CRAN incoming feasibility ... [13s] NOTE
Maintainer: 'Hume Winzar <winzar@gmail.com>'
   
* checking CRAN incoming feasibility ... [11s] NOTE
Maintainer: 'Hume Winzar <winzar@gmail.com>'


#### downstream dependencies

None currently



#### This is a resubmission

Many thanks to Victoria Wimmer for her patience as a reviewer


in DEsCRIPTION file, I have:

* ensured package names with single quotes in description field

* Fixed function names with correct `function_name()` 

* Improved grammar and fixed a typo


in the vignette file, I have

* added a References list to accompany the in-line references in the document


in the README file, I have

* added references to other package used

* included Project Status: Active badge


also, I have:

* included a _codemeta.json_ file



#### In the second resubmission

I have:

* expanded the description field in the DESCRIPTION file

* cited the _DEoptim_ package on which the _lexact()_ function is based

* included detailed citations for alternative packages in the vignette


##### In the first resubmission

I have:

* updated LICENSE file in accord with CRAN template

* updated "lexact.R" optimisation function file for shorter runtime

* simplified examples for shorter runtime

* removed an example from vignette file for shorter runtime  

## ----
    
── R CMD check results ────────── LikertMakeR 0.1.5 ────
Duration: 1m 15.9s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

R CMD check succeeded
