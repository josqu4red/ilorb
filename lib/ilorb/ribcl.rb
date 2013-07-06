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

    [:context, :mode, :attributes, :elements, :text].each do |key|
      define_method "has_#{key}?" do |command|
        self.has_key?(command) and self[command].has_key?(key) ? true : false
      end

      define_method "get_#{key}" do |command|
        self.send("has_#{key}?", command) ? self[command][key] : nil
      end
    end

    def is_implemented?(command)
      has_command?(command) and !self[command].has_key?(:implemented)
    end

    def map_elements(command)
      map = {}
      if has_elements?(command)
        get_elements(command).each do |name, type|
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
      end
      map
    end

    def encode(value)
      VALUES[value] ? VALUES[value] : value
    end

    private

    # no use for now
    #def get_params(command)
    #  params = []
    #  params += get_attributes(command).map{|a| a.to_s} if has_attributes?(command)
    #  params << get_text(command).to_s if has_text?(command)
    #  params += map_elements(command).keys if has_elements?(command)
    #  params
    #end

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
      @elements = {}
      @text = nil
      @not_implemented = false
    end

    def to_hash
      contents = {}
      if @not_implemented
        contents.store(:implemented, false)
      else
        # "Command" element has either children or text
        if @text
          contents.store(:text, @text) if @text
        else
          contents.store(:elements, @elements) unless @elements.empty?
        end
        contents.store(:attributes, @attributes) unless @attributes.empty?
      end
      {@name => contents}
    end

    private

    def attributes(*params)
      @attributes += params
    end

    def elements(*params)
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

    def text(param)
      @text = param
    end

    def not_implemented
      @not_implemented = true
    end
  end
end
