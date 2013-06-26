module HP
  module CG
    def self.commands(context, &block)
      command_set = CommandSet.new(context)
      command_set.instance_eval(&block)
      p command_set.commands
    end

    class CommandSet
      attr_reader :commands
      def initialize(name)
        @context = name.to_sym
        @modes = [:read, :write]
        @commands = {}
      end

      def method_missing(name, *args, &block)
        if name =~ /^(\w+)_command$/ and @modes.include?($1.to_sym) and args.length == 1
          c = Command.new(args.first, @context, $1)
          c.instance_eval(&block) if block_given?
          @commands.merge! c.to_hash
        else
        end
      end

      def respond_to?(name)
        name =~ /^(\w+)_command$/ and @modes.include?($1.to_sym) ? true : super
      end
    end

    class Command
      def initialize(name, context, mode)
        @name = name
        @attributes = {}
        @elements = {}
        @context = context
        @mode = mode
      end

      def attributes(hash)
        @attributes.merge! hash
      end

      def elements(hash)
        @elements.merge! hash
      end

      def to_hash
        {@name.to_sym => {:context => context, :mode => mode, :attributes => @attributes, :elements => @elements}}
      end

      private

      def context
        "#{@context}_info".to_sym
      end

      def mode
        @mode.to_sym
      end
    end
  end
end
