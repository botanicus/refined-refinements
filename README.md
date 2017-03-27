# About

Collection of core class extensions I found useful across multiple projects. They are implemented as refinements, they do not override the global scope, so are safe to use.

Refinements allow you to redefine methods on core classes only within given context. For instance if you have class Foo and you want to redefine String#gsub only within that class, you can do so using refinements. Magnus Holm wrote a nice [intro into refinements](http://timelessrepo.com/refinements-in-ruby).

## RR::ColourExts

```ruby
require 'refined-refinements/colours'

using RR::ColourExts

puts '<green>Hello <red.bold>world</red.bold></green>!'.colourise
puts '<green>Hello <red.bold>world</red.bold></green>!'.colourise(bold: true)
```

## RR::MatchingExts

```ruby
require 'refined-refinements/matching'

using RR::MatchingExts

string = 'Hello <bold>bold</bold> world!'
regexp = /
  <(?<tag_name>[^>]+)>
  (?<inner_text>.+)
  <\/\k<tag_name>>
/x

string.sub(regexp) do |match, text_before_match, text_after_match|
  p [:m, match]
  p [:b, text_before_match]
  p [:a, text_after_match]
end

# [:m, #<MatchData "<bold>bold</bold>" tag_name:"bold" inner_text:"bold">]
# [:b, "Hello "]
# [:a, " world!"]
```

## RR::MatchingExts

```ruby
require 'refined-refinements/string'

using RR::StringExts

puts 'hello world!'.titlecase

# Hello world!
```
