module DocHelper

  ##
  # Translates a Namespace::Constant::Class#Method into a YARD documentation link:
  #   doc('Adapters::AbstractAdapter', 'transaction_primitive')
  #   # => http://datamapper.rubyforge.org/DataMapper/Adapters/AbstractAdapter.html#transaction_primitive-instance_method
  #
  #   doc('DataMapper::Adapters')
  #   # => http://datamapper.rubyforge.org/DataMapper/Adapters.html
  #
  # @param [String] klass the class name with namespacing to link to.
  #   'DataMapper::' is prepended to the string if it doesn't already start with it
  #
  # @param [String] method (optional) method name to append to the link
  #
  # @param [Symbol(:instance, :class)] method_level the method-level (instance, class)
  #   of the method. defaults to :instance
  #
  # @raise [ArgumentError] if you supply an invalid method_level
  #
  def doc(klass, method = nil, method_level = :instance)
    #
    # TODO: make this recognize DM:: as well
    # TODO: make this ALOT smarter...perhaps dynamically store the whole DM namespace, if that's possible?
    #
    raise ArgumentError, 'method_level must be :instance or :class' unless [:instance, :class].include?(method_level)

    link = %Q{http://datamapper.rubyforge.org/}

    link << "DataMapper/" unless klass[/^DataMapper::/]

    link << klass.gsub("::","/") << ".html"
    if method
      link << "##{method.downcase.underscore}" if method
      link << "-#{method_level}_method"
    end
    out = %Q{<a href="#{link}">#{klass}</a>}
  end
end

Webby::Helpers.register(DocHelper)
