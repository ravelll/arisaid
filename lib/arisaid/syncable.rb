module Arisaid
  module Syncable
    attr_writer :local_file

    def local_file
      name = self.class.name.split('::').last.downcase
      @local_file ||=
        "#{Arisaid.conf_prefix if Arisaid.conf_prefix}#{name}.yml"
    end

    def local_file_path
      File.join(Dir.pwd, local_file)
    end

    def remote
      @remote || remote!
    end

    def remote!
    end

    def local
      local_by_stdin || local_by_file
    end

    def local_by_stdin
      if File.pipe?(STDIN) || File.select([STDIN], [], [], 0) != nil
        buffer = ''
        while str = STDIN.gets
          buffer << str
        end
        buffer.chomp
      end
    end

    def local_by_file
      unless File.exists?(local_file_path)
        raise Arisaid::ConfNotFound.new("Not found: #{local_file_path}")
      end
      YAML.load_file(local_file_path)
    end

    def initialize(team = nil)
      Arisaid.slack_team = team if team
    end

    def show
      puts remote.to_yaml
    end

    def apply
    end

    def same?(src, dst)
      src == dst
    end

    def save
      File.write local_file_path, remote.to_yaml
    end
  end
end