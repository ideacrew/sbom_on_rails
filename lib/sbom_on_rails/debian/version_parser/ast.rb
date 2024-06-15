module SbomOnRails
  module Debian
    module VersionParser
      module Ast
        class NormalVersionSyntaxNode < Treetop::Runtime::SyntaxNode
        end

        class PrefixSyntaxNode < Treetop::Runtime::SyntaxNode
        end

        class VersionSyntaxNode < Treetop::Runtime::SyntaxNode
        end
      end
    end
  end
end