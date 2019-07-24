module Foreman
  module Renderer
    module Scope
      module Macros
        module HostTemplate
          extend ApipieDSL::Module
          include Foreman::Renderer::Errors

          # FIXME seems to be ignored
          # FIXME need a long decription
          # TODO incomplete
          apipie :method, desc: "Returns a host ENC representation" do
                 # long_description: "Every template can be parametrized with inputs. Input needs to be explicitly defined
                 #   and can be of various type. During the rendering all required inputs needs to be fed with the value.
                 #   Most commonly, user inputs are used in report and job templates. For such input, user is requested
                 #   to provide values before the template rendering is performed. The input macro is substitued by the
                 #   corresponding value that was provided." do
            required :path, String, desc: 'expanded array of strings definining a subtree of ENC output'
            returns Hash, desc: 'part of the ENC output for a given host'
            raises error: KeyError, desc: 'when user asks for invalid path.'
            example "host_enc # => "
            example "host_enc('a') # => "
            example "host_enc('a', 'b') # => "
          end
          def host_enc(*path)
            check_host
            return enc if path.compact.empty?
            path.reduce(enc) do |e, step|
              begin
                e.fetch(step)
              rescue KeyError
                raise HostENCParamUndefined.new(name: path, step: step, host: host)
              end
            end
          end

          def host_param(param_name, default = nil)
            check_host
            host.host_param(param_name) || default
          end

          def host_param!(param_name)
            check_host_param(param_name)
            host_param(param_name)
          end

          def host_puppet_classes
            check_host
            host.puppetclasses
          end

          def host_param_true?(name)
            check_host
            host.params.has_key?(name) && Foreman::Cast.to_bool(host.params[name])
          end

          def host_param_false?(name)
            check_host
            host.params.has_key?(name) && Foreman::Cast.to_bool(host.params[name]) == false
          end

          def root_pass
            check_host
            host.root_pass
          end

          def grub_pass
            return '' unless @grub
            host.grub_pass.start_with?('$1$') ? "--md5pass=#{host.grub_pass}" : "--iscrypted --password=#{host.grub_pass}"
          end

          def ks_console
            (@port && @baud) ? "console=ttyS#{@port},#{@baud}" : ''
          end

          private

          def enc
            @enc ||= host.info.deep_dup
          end

          def check_host
            raise HostUnknown if host.nil?
          end

          def check_host_param(name)
            check_host
            raise HostParamUndefined.new(name: name, host: host) unless host.params.key?(name)
          end
        end
      end
    end
  end
end
