\version "2.14.2"
<<
  \new Staff {
    \set Staff.instrumentName = #"cantus" 
    \clef treble
    \key c \major
    \relative c'' { c1 g f e g a b c \bar "|." }
  }
  \new Staff {
    \set Staff.instrumentName = #"counterpoint" 
    \clef bass
    \key c \major
    \relative c { c1 e a g e f d c \bar "|." }
  }
>>
