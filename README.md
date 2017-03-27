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
