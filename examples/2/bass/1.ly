\version "2.14.2"
<<
  \new Staff {
    \set Staff.instrumentName = #"counterpoint"
    \clef treble
    \key c \major
    \relative c' { c1 g' a b a c b c \bar "|." }
  }
  \new Staff {
    \set Staff.instrumentName = #"cantus" 
    \clef bass
    \key c \major
    \relative c { c1 b a g c e d c \bar "|." }
  }
>>
