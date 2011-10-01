\version "2.14.2"
<<
  \new Staff {
    \set Staff.instrumentName = #"cantus" 
    \clef treble
    \key c \major
    \relative c'' { c1 e a g e f d c \bar "|." }
  }
  \new Staff {
    \set Staff.instrumentName = #"counterpoint" 
    \clef bass
    \key c \major
    \relative c { c1 a f g a d b c \bar "|." }
    % there is an arpeggio, but given the nice tonal movement in the bass it is allowed
  }
>>
