
\paper{
  annotate-spacing = ##f
make-footer = ##f
top-margin = 0.8\in
bottom-margin = 0.8\in
  
  
  ragged-bottom = ##f
  ragged-bottom-last = ##f
}

%{
  Partition produite avec RLily et Lilypond
%}
\version "2.18.2"



\header {
  title = "Essai"
  
  composer = "Phil"
  
  
  
}


\score{
  \new PianoStaff \with {
    \override StaffGrouper.staff-staff-spacing = #'(
      (basic-distance . 3)
      (padding . 3))
  }
  <<
  \new Staff {
  
  \clef treble
  \relative c' {
    \time 4/4
    \override Fingering.direction = #UP
    \hide Rest \hide Staff.BarLine <ges' bes des>2 <ges beses des>
  }
}

  \new Staff {
  
  \clef bass
  \relative c {
    \time 4/4
    \override Fingering.direction = #DOWN
    \hide Staff.BarLine \hide Stem \hide Rest \hide NoteHead \hide Slur \hide Beam \stopStaff r1 r
  }
}

>>

  \layout{
  }
}
