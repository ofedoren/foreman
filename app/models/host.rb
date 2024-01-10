module Host
  def self.method_missing(method, *args, **kwargs, &block)
    type = "Host::Managed"
    case method.to_s
    when /create/, 'new'
      # in this case args should contain a hash with host attributes
      if args.empty? || args[0].nil? # got no parameters
        # set the default type
        args = [{:type => type}]
      else # got some parameters
        args[0][:type] ||= type # adds the type if it doesn't exists
        type = args[0][:type]   # stores the type for later usage.
      end
      # require 'pry-byebug'; binding.pry if args != [{type: "Host::Managed"}] || !kwargs.empty?
      type.constantize.send(method, kwargs.merge(args.first), &block)
    else
      klass = type.constantize
      if klass.respond_to?(method, true)
        # unless [
        #   :allows_location_filtering?, :unscoped, :humanize_class_name, :allows_organization_filtering?,
        #   :search_for,
        # ].include?(method.to_sym)
        # require 'pry-byebug'; binding.pry
        # end
        # require 'pry-byebug'; binding.pry unless type == 'Host::Managed'
        # require 'pry-byebug'; binding.pry if !kwargs.empty? && method == :where
        # Removing block, since we will pass it anyway
        meth_params = klass.method(method).parameters.collect { |par_desc| par_desc.first } - [:block]
        # require 'pry-byebug'; binding.pry if method.to_s == 'find_by'
        if meth_params.empty? || (args.empty? && kwargs.empty?)
          klass.send(method, &block)
        elsif meth_params == [:rest]
          # means that the method could accept anything, e.g. def find_by(*args),
          # but internally would expect a Hash wrapped by *args array
          # or there are cases like Array#last, which has * as param list, but expects an Integer
          # since there is a lot of delegation in Rails, it's hard to know exact signature of the real method:
          # find_in_batches expects only kwargs, but method(:find_in_batces) returns (*) as param list
          # through the same delegation goes find_by with a different signature/expectations

          # if args.empty? && kwargs.any?
          #   merged_args = args.push(kwargs)
          #   klass.send(method, *merged_args, &block)
          # else
          #   klass.send(method, *args, &block)
          # end
          if !args.empty?
            klass.send(method, *args, &block)
          elsif kwargs.any?
            klass.send(method, **kwargs, &block)
          end
        elsif (meth_params & [:req, :opt, :rest]).empty?
          # this would mean we pass kwargs only
          klass.send(method, **kwargs, &block)
        elsif (meth_params & [:key, :keyreq, :keyrest]).empty?
          # if there is no kwargs, let's treat this as before
          klass.send(method, *args, &block)
        else
          # let's treat as we should
          klass.send(method, *args, **kwargs, &block)
        end
      else
        super
      end
    end
  end

  # the API base controller expects to call 'respond_to?' on this, which
  # this module doesn't have. So we stub it out to make that logic work for
  # the "find_by_*" classes that Rails will provide
  def self.respond_to_missing?(method, include_private = false)
    method.to_s =~ /\Afind_by_(.*)\Z/ || method.to_s.include?('create') ||
      [:reorder, :new].include?(method) || super
  end
end
