
\paper{
    indent           = 0\mm
  line-width       = 120\mm
  oddFooterMarkup  = ##f
  oddHeaderMarkup  = ##f
  bookTitleMarkup  = ##f
  scoreTitleMarkup = ##f
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
    \hide Rest \hide Staff.BarLine c disis e f g <gis beses des>2
  }
}

  
>>

  \layout{
  }
}
