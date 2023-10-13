# include this module to translate in all domains by default
module Foreman
  module Gettext
    module AllDomains
      class Localizator
        prepend FastGettext::TranslationMultidomain
      end

      def self.localizator
        @localizator ||= Localizator.new
      end

      def _(key)
        Foreman::Gettext::AllDomains.localizator.D_(key)
      end

      def n_(*keys)
        Foreman::Gettext::AllDomains.localizator.Dn_(*keys)
      end

      def s_(key, separator = nil)
        Foreman::Gettext::AllDomains.localizator.Ds_(key, separator)
      end

      def ns_(*keys)
        Foreman::Gettext::AllDomains.localizator.Dns_(*keys)
      end
    end
  end
end
