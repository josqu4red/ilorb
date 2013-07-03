module ILORb
  class RIBCL < Hash
    def initialize
      super
    end

    VALUES = {
      true => "yes",
      false => "no",
    }

    alias_method :has_command?, :has_key?

    [:context, :mode, :attributes, :elements].each do |key|
      define_method "has_#{key}?" do |command|
        self.has_key?(command) and self[command].has_key?(key) ? true : false
      end

      define_method "get_#{key}" do |command|
        self.send("has_#{key}?", command) ? self[command][key] : nil
      end
    end

    def context(name, &block)
      context = Context.new(name)
      context.instance_eval(&block)
      merge!(context.commands)
    end

    def encode(value)
      VALUES[value] ? VALUES[value] : value
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
      @attributes = []
      @elements = []
    end

    [:attributes, :elements].each do |container|
      define_method container do |*param|
        if param.is_a?(Array)
          array = param
        else
          [ param ]
        end
        instance_variable_set("@#{container}", instance_variable_get("@#{container}").concat(array))
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
