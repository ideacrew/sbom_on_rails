module SbomOnRails
  module Utils
    class Whicher
      def self.find(*commands)
        commands.map { |c| find_command(c) }.compact.first
      end

      protected

      def self.find_command(cmd)
        exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
        ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
          exts.each do |ext|
            exe = File.join(path, "#{cmd}#{ext}")
            return exe if File.executable?(exe) && !File.directory?(exe)
          end
        end
        nil
      end
    end
  end
end