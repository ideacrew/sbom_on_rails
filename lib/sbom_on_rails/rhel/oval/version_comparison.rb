module SbomOnRails
  module Rhel
    module Oval
      # Compare versions
      class VersionComparison
        def self.run(package_version, comparer, test_version)
          case comparer
          when :lte
            package_version.comp(test_version) < 1
          when :gte
            package_version.comp(test_version) > -1
          when :gt
            package_version.comp(test_version) > 0
          else
            package_version.comp(test_version) < 0
          end
        end
      end
    end
  end
end