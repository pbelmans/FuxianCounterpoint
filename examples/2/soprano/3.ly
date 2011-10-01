\version "2.14.2"
<<
  \new Staff {
    \set Staff.instrumentName = #"cantus" 
    \clef treble
    \key c \major
    \relative c'' { c1 b a g c e d c \bar "|." }
  }
  \new Staff {
    \set Staff.instrumentName = #"counterpoint" 
    \clef bass
    \key c \major
    \relative c { c1 d f g a c b c \bar "|." }
  }
>>
