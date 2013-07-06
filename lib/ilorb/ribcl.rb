module ILORb
  class RIBCL < Hash
    def initialize
      super
    end

    # meaningful aliases
    alias_method :has_command?, :has_key?
    alias_method :command, :fetch

    # mapping between Ruby objects and api format
    VALUES = {
      true => "yes",
      false => "no",
    }

    def self.load(path)
      obj = new
      Dir.glob(path).each do |file|
        obj.instance_eval(File.read(file), file)
      end
      obj
    end

    def encode(value)
      VALUES[value] ? VALUES[value] : value
    end

    private
    # private methods are used by DSL

    def context(name, &block)
      context = Context.new(name)
      context.instance_eval(&block)
      merge!(context.commands)
    end
  end

  class Context
    attr_reader :commands

    def initialize(name)
      @name = name.to_sym
      @commands = {}
    end

    private
    # private methods are used by DSL

    [:read, :write].each do |mode|
      define_method "#{mode}_cmd" do |name, &block|
        command = Command.new(name, @name, mode)
        command.instance_eval(&block) if block
        @commands[name] = command
      end
    end
  end

  class Command
    attr_reader :name, :context, :mode

    def initialize(name, context, mode)
      @name, @context, @mode = name.to_sym, context, mode
      @attributes = []
      @elements = {}
      @text = nil
      @supported = true
    end

    [:attributes, :elements, :text].each do |key|
      define_method "get_#{key}" do
        instance_variable_get("@#{key}")
      end
    end

    def supported?
      @supported
    end

    def map_elements
      map = {}
      @elements.each do |name, type|
        if type == :value
          map.store(name, [name, type])
        elsif type.is_a?(Array)
          type.each do |elt|
            map.store("#{name}_#{elt}".to_sym, [name, elt])
          end
        else
          map.store("#{name}_#{type}".to_sym, [name, type])
        end
      end
      map
    end

    def get_params
      params = []
      params += @attributes
      params << @text if @text
      params += map_elements.keys
      params
    end

    private
    # private methods are used by DSL

    def attributes(*params)
      @attributes += params
    end

    def elements(*params)
      if @text.nil?
        hash = {}
        params.each do |param|
          if param.is_a?(Hash)
            hash.merge!(param)
          else
            hash.store(param, :value)
          end
        end
        @elements.merge!(hash)
      end
    end

    def text(param)
      if @elements.empty?
        @text = param
      end
    end

    def not_implemented
      @supported = false
    end
  end
end
