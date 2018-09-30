module ACERA
  module CoreExts
    # Counter-intuitively when regexp replacement methods are called with a block,
    # the first and only block argument is the whole match as a string.
    #
    # There is no way to get match groups and the string before and after the match
    # other than using global variables such as $~, $1, $` etc.
    #
    # The problem with that, besides readability and violations of basic
    # industry practices, is that the minute you use another String#sub or
    # String#match, these variables gets reassigned.
    #
    # With this refinement you can access these variables through block arguments:
    #
    #   using ACERA::CoreExts
    #
    #   'Hello world!'.sub(/(?<word>[a-zA-Z]+)/) do |match, string_before_match, string_after_match|
    #     match[:word].upcase
    #   end

    refine String do
      [:sub, :sub!, :gsub, :gsub!].each do |method_name|
        define_method(method_name) do |*args, &block|
          if block
            super(*args) { block.call($~, $`, $') }
          else
            super(*args)
          end
        end
      end
    end
  end
end
