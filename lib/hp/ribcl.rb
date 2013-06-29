module HP
  class RIBCL
    attr_reader :commands

    def initialize
      @commands = {}
    end

    def context(name, &block)
      context = Context.new(name)
      context.instance_eval(&block)
      @commands.merge! context.commands
    end
  end

  class Context
    attr_reader :commands

    def initialize(name)
      @name = name.to_sym
      @commands = {}
    end

    [:read, :write].each do |mode|
      define_method "#{mode}_cmd" do |name, &block|
      command = Command.new(name)
      command.instance_eval(&block) if block
      result = command.to_hash
      result[name].store(:context, @name)
      result[name].store(:mode, mode)
      @commands.merge!(result)
      end
    end
  end

  class Command
    def initialize(name)
      @name = name.to_sym
      @attributes = {}
      @elements = {}
    end

    [:attributes, :elements].each do |container|
      define_method container do |*param|
        if param.is_a?(Hash)
          hash = param
        elsif param.is_a?(Array)
          hash = Hash[param.map{|x|[x]}]
        else
          { param => nil }
        end
        instance_variable_set("@#{container}", instance_variable_get("@#{container}").merge(hash))
      end
    end

    def to_hash
      contents = {}
      contents.store(:attributes, @attributes) unless @attributes.empty?
      contents.store(:elements, @elements) unless @elements.empty?
      {@name => contents}
    end
  end
end
