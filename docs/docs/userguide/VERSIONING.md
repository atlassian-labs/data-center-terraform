# Versioning

## Release naming

Each product version is [semantically versioned](https://semver.org/){.external}. Version names are defined by the following pattern: `v-MAJOR.MINOR.PATCH`, e.g. `v1.2.3`. 

## Release versions

The version number for the first GA release starts from `1.0.0` and next release versions will be defined based on the nature of the delivered changes:

- If there is at least one backward-incompatible change, then the next version will be the next major version. 
- If at least one functional change is delivered and all changes are backward-compatible, then the next release will be the next minor version.
- Any other backward-compatible bug fixes will be included in the next patch version. 

!!! Info "Breaking changes"
    Any backward-incompatible changes to the infrastructure should bump the major version number.


