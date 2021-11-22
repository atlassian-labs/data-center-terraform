# Versioning

## Release naming
Each product version is [semantically versioned](https://semver.org/){.external}. 
Version name will be defined by the following pattern: `tf-<product>-MAJOR.MINOR.PATCH` , e.g. `tf-bamboo-0.0.1`. 

## Release versions
The version number for first release starts from `0.0.1` and next release versions will be defined based on the nature of the delivered changes:

If there is at least one change that breaks upgrading from the previous version (backwards incompatible), then the next version will be the next MAJOR version. 
If at least one functional change is delivered and all changes are backward compatible, then the next release will be the next MINOR version. 
Any other backward compatible bug fix will be in the next PATCH version. 

!!! Info "Breaking changes"
    Any backwards-incompatible changes to the infrastructure should bump the MAJOR version.


