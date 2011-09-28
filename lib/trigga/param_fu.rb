module Trigga
  module ParamFu
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
    end
    
    module ClassMethods
      def require_obj_or_id(opts, key)
        obj_or_id(opts,key)
        raise ArgumentError.new("#{key} or #{key_with_id(key)} are required") unless opts[key_with_id(key)]
        opts
      end
      
      def require_param(opts, *keys)
        keys.to_a.each do |k|
          raise ArgumentError.new("#{k} is required") unless opts[k]
        end
        opts
      end

      def obj_or_id(opts, key)
        opts[key_with_id(key)] ||= opts[key].id if opts[key]
      end
      
      def key_with_id(key)
        (key.to_s + '_id').to_sym
      end
      
      def require_one_of( opts, *keys )
        present = (opts.keys & keys)
        raise ArgumentError.new( "at least one of the arguments #{keys.inspect} is required" ) if present.empty?
        return present
      end
    end
    
    module InstanceMethods
      def require_obj_or_id(opts,key)
        self.class.require_obj_or_id(opts, key)
      end
      def obj_or_id(opts, key)
        self.class.obj_or_id(opts, key)
      end
      def require_param(opts, *keys)
        self.class.require_param(opts, *keys)
      end
      def require_one_of( opts, *keys )
        self.class.require_one_of( opts, *keys )
      end
    end
  end
end


class Hash
  # Allows you to convert a hash to an array suitable for use in an ActiveRecord finder conditions clause
  #
  # @allowed_keys optional  an array of param names to include - if given, any keys NOT in this array will be excluded
  # @column_aliases optional  a hash of param name => column name mappings, for the case where the param name needs mapping to an alternative column name
  # e.g. 
  #  {:fish=>'trout', :cheese=>'gruyere', :rodent=>'vole'}.to_conditions( [:fish, :cheese], {:cheese=>:fromage})
  #   => ["(fish = ?) AND (fromage = ?)", 'trout', 'gruyere']
  def to_conditions( allowed_keys, column_aliases={} )
    conds = [ [] ]
    allowed_keys ||= keys 
    allowed_keys.to_a.each do |k|
      
      this_key =  ( keys.include?(k.to_sym) ? k.to_sym : (keys.include?(k.to_s) ? k.to_s : nil))
      next unless this_key
      next if self[this_key].blank?
      
      conds[0] << "#{column_aliases[this_key.to_sym] ? column_aliases[this_key.to_sym] : this_key.to_s} = ?"
      conds << self[this_key]
    end
    
    conds[0] = conds[0].map{ |c| "(#{c})" }.join( " AND " )
    conds
  end  
end
