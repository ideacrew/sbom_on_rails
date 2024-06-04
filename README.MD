# SBOM On Rails

This gem assists in the generation of SBOM files for rails projects which use both RubyGems and other dependency types, such as javascript.

## Phases

Each SBOM generation goes through one or more phases:
1. Generate the RubyGem dependency SBOM
2. Generate other SBOMs (most commonly for NPM packges)
3. Merge previous SBOMs in to a single artifact

## Supported Tools

Right now, the project supports SBOM generation for:
1. RubyGems via GemReport
2. NPM via CycloneDX NPM