module Foreman
  module Renderer
    module DocTemplates
      module BasicRubyMethods
        module Object
          extend ApipieDSL::Module

          apipie_class 'Object', 'Methods in here can be applied to any Ruby object' do
            sections only: %w[basic_ruby_methods]
          end

          apipie_method :blank?, 'Returns true if object is blank.' do
            desc 'An object is blank if it’s false, empty, or a whitespace string.'
            returns one_of: [true, false]
            example "[1, 2].blank?    #=> false
''.blank?   #=> true"
          end
        end

        module Integer
          extend ApipieDSL::Module

          apipie_class 'Integer' do
            sections only: %w[basic_ruby_methods]
          end

          apipie_method :id2name, 'Returns the name of the object whose symbol id is fix.' do
            desc 'If there is no symbol in the symbol table with this value, returns nil.
              id2name has nothing to do with the Object.id method.'
            returns one_of: [String, nil], desc: 'The name of the object.'
            example "symbol = :@inst_var    #=> :@inst_var
id     = symbol.to_i   #=> 9818
id.id2name             #=> '@inst_var'"
          end
        end

        module Array
          extend ApipieDSL::Module

          apipie_class 'Array' do
            sections only: %w[basic_ruby_methods]
          end

          apipie_method :map, 'Returns a new array with the results of running block once for every element in enum.' do
            block 'Optional. If no block is given, an enumerator is returned instead.', schema: '{ |obj| block }'
            returns ::Array, 'New array with the results of running block'
            example "(1..4).map { |i| i*i }      #=> [1, 4, 9, 16]"
          end
        end
      end
    end
  end
end
