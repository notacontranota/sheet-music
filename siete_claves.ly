\version "2.19.83"
%\include "lilypond-book-preamble.ly"
%Función para generar líneas de pentagrama con colores
#(define-public ((color-staff-lines . rest) grob)

   (define (index-cell cell dir)
     (if (equal? dir RIGHT)
         (cdr cell)
         (car cell)))

   (define (index-set-cell! x dir val)
     (case dir
       ((-1) (set-car! x val))
       ((1) (set-cdr! x val))))

   (let* ((common (ly:grob-system grob))
          (span-points '(0 . 0))
          (thickness (* (ly:grob-property grob 'thickness 1.0)
                        (ly:output-def-lookup (ly:grob-layout grob) 'line-thickness)))
          (width (ly:grob-property grob 'width))
          (line-positions (ly:grob-property grob 'line-positions))
          (staff-space (ly:grob-property grob 'staff-space 1))
          (line-stencil #f)
          (total-lines empty-stencil)
          ;; use a local copy of colors list, since
          ;; stencil creation mutates list
          (colors rest))

     (for-each
      (lambda (dir)
        (if (and (= dir RIGHT)
                 (number? width))
            (set-cdr! span-points width)
            (let* ((bound (ly:spanner-bound grob dir))
                   (bound-ext (ly:grob-extent bound bound X)))
              
              (index-set-cell! span-points dir
                               (ly:grob-relative-coordinate bound common X))
              (if (and (not (ly:item-break-dir bound))
                       (not (interval-empty? bound-ext)))
                  (index-set-cell! span-points dir 
                                   (+ (index-cell span-points dir)
                                      (index-cell bound-ext dir))))))
        (index-set-cell! span-points dir (- (index-cell span-points dir)
                                            (* dir thickness 0.5))))
      (list LEFT RIGHT))

     (set! span-points
           (coord-translate span-points
                            (- (ly:grob-relative-coordinate grob common X))))
     (set! line-stencil
           (make-line-stencil thickness (car span-points) 0 (cdr span-points) 0))

     (if (pair? line-positions)
         (for-each (lambda (position)
                     (let ((color (if (pair? colors)
                                      (car colors)
                                      #f)))
                       (set! total-lines
                             (ly:stencil-add
                              total-lines
                              (ly:stencil-translate-axis
                               (if (color? color)
                                   (ly:stencil-in-color line-stencil
                                                        (first color)
                                                        (second color)
                                                        (third color))
                                   line-stencil)
                               (* position staff-space 0.5) Y)))
                       (and (pair? colors)
                            (set! colors (cdr colors)))))
                   line-positions)       
         (let* ((line-count (ly:grob-property grob 'line-count 5))
                (height (* (1- line-count) (/ staff-space 2))))
           (do ((i 0 (1+ i)))                      
               ((= i line-count))
             (let ((color (if (and (pair? colors)
                                   (> (length colors) i))
                              (list-ref colors i)
                              #f)))
               (set! total-lines (ly:stencil-add
                                  total-lines
                                  (ly:stencil-translate-axis
                                   (if (color? color)
                                       (ly:stencil-in-color line-stencil
                                                            (first color)
                                                            (second color)
                                                            (third color))
                                       line-stencil)
                                   (- height (* i staff-space)) Y)))))))
     total-lines))

%Usa como "compás" la clave de Sol y de Fa
claveSolFa = \markup {
  \null
  \right-column {
    { \raise #2 \musicglyph "clefs.G" }
    { \raise #1 \musicglyph "clefs.F" }
  }
}

%Claves de Do, Sol y Fa
clavesIniciales = {
  \override Staff.StaffSymbol.line-positions = #'(-10 -8 -6 -4 -2 0 2 4 6 8 10)
  \override Staff.StaffSymbol.stencil = #(color-staff-lines #f #f #f #f #f red)
  \clef alto
  \override Staff.TimeSignature #'stencil = #ly:text-interface::print
  \override Staff.TimeSignature #'text = \claveSolFa
  c'1_\markup { \concat { "Do" \sub "4" } }
  \stopStaff
}

%espacio gris
espacioGris = {
  \override Staff.StaffSymbol.stencil = #(color-staff-lines (rgb-color 0.8 0.8 0.8) (rgb-color 0.8 0.8 0.8) (rgb-color 0.8 0.8 0.8) (rgb-color 0.8 0.8 0.8) (rgb-color 0.8 0.8 0.8)  red (rgb-color 0.8 0.8 0.8) (rgb-color 0.8 0.8 0.8) (rgb-color 0.8 0.8 0.8) (rgb-color 0.8 0.8 0.8) (rgb-color 0.8 0.8 0.8) )
  \startStaff
  s1
  \stopStaff
}

%Clave de Fa en 4ta.
claveDeFaEnCuarta = {
  \override Staff.StaffSymbol.stencil = #(color-staff-lines #f #f #f #f #f red (rgb-color 0.8 0.8 0.8) (rgb-color 0.8 0.8 0.8) (rgb-color 0.8 0.8 0.8) (rgb-color 0.8 0.8 0.8) (rgb-color 0.8 0.8 0.8) )
  \startStaff
  \set Staff.clefGlyph = #"clefs.F"
  \set Staff.clefPosition = #-4
  \set Staff.middleCPosition = #0
  \set Staff.middleCClefPosition = #0
  s_\markup { \center-align \rotate #90 { \right-column {"Clave de Fa en 4ª" \italic "Bajo"} }}
  \stopStaff
}

%Clave de Fa en 3ra.
claveDeFaEnTercera = {
  \override Staff.StaffSymbol.stencil = #(color-staff-lines (rgb-color 0.8 0.8 0.8)  #f #f #f #f #f (rgb-color 0.8 0.8 0.8) (rgb-color 0.8 0.8 0.8) (rgb-color 0.8 0.8 0.8) (rgb-color 0.8 0.8 0.8) (rgb-color 0.8 0.8 0.8) )
  \startStaff
  \set Staff.forceClef = ##t
  \set Staff.clefGlyph = #"clefs.F"
  \set Staff.clefPosition = #-4
  \set Staff.middleCPosition = #0
  \set Staff.middleCClefPosition = #0
  s_\markup { \center-align \rotate #90 { \right-column {"Clave de Fa en 3ª" \italic "Barítono"} }}
  \stopStaff
}

%Clave de Do en 4ta.
claveDeDoEnCuarta = {
  \override Staff.StaffSymbol.stencil = #(color-staff-lines (rgb-color 0.8 0.8 0.8) (rgb-color 0.8 0.8 0.8) #f #f #f red #f (rgb-color 0.8 0.8 0.8) (rgb-color 0.8 0.8 0.8)  (rgb-color 0.8 0.8 0.8) (rgb-color 0.8 0.8 0.8) )
  \startStaff
  \set Staff.forceClef = ##t
  \set Staff.clefGlyph = #"clefs.C"
  \set Staff.clefPosition = #0
  \set Staff.middleCPosition = #0
  \set Staff.middleCClefPosition = #0
  s_\markup { \center-align \rotate #90 { \right-column {"Clave de Do en 4ª" \italic "Tenor"} }}
  \stopStaff
}
  
%Clave de Do en 3ra.
claveDeDoEnTercera = {
  \override Staff.StaffSymbol.stencil = #(color-staff-lines (rgb-color 0.8 0.8 0.8)(rgb-color 0.8 0.8 0.8)(rgb-color 0.8 0.8 0.8)#f #f red #f #f (rgb-color 0.8 0.8 0.8)(rgb-color 0.8 0.8 0.8)(rgb-color 0.8 0.8 0.8))
  \startStaff
  \set Staff.forceClef = ##t
  \set Staff.clefGlyph = #"clefs.C"
  \set Staff.clefPosition = #0
  \set Staff.middleCPosition = #0
  \set Staff.middleCClefPosition = #0
  s_\markup { \center-align \rotate #90 { \right-column {"Clave de Do en 3ª" \italic "Contralto"} }}
  \stopStaff
}

%Clave de Do en 2da.
claveDeDoEnSegunda = {
  \override Staff.StaffSymbol.stencil = #(color-staff-lines (rgb-color 0.8 0.8 0.8) (rgb-color 0.8 0.8 0.8) (rgb-color 0.8 0.8 0.8) (rgb-color 0.8 0.8 0.8) #f red #f #f #f (rgb-color 0.8 0.8 0.8) (rgb-color 0.8 0.8 0.8) )
  \startStaff
  \set Staff.forceClef = ##t
  \set Staff.clefGlyph = #"clefs.C"
  \set Staff.clefPosition = #0
  \set Staff.middleCPosition = #0
  \set Staff.middleCClefPosition = #0
  s_\markup { \center-align \rotate #90 { \right-column {"Clave de Do en 2ª" \italic "Mezzosoprano"} }}
  \stopStaff
}

%Clave de Do en 1ra.
claveDeDoEnPrimera = {
  \override Staff.StaffSymbol.stencil = #(color-staff-lines (rgb-color 0.8 0.8 0.8)(rgb-color 0.8 0.8 0.8)(rgb-color 0.8 0.8 0.8)(rgb-color 0.8 0.8 0.8)(rgb-color 0.8 0.8 0.8) #f #f #f #f #f (rgb-color 0.8 0.8 0.8) )
  \startStaff
  \set Staff.forceClef = ##t
  \set Staff.clefGlyph = #"clefs.C"
  \set Staff.clefPosition = #0
  \set Staff.middleCPosition = #0
  \set Staff.middleCClefPosition = #0
  s_\markup { \center-align \rotate #90 { \right-column {"Clave de Do en 1ª" \italic "Soprano (antigua)"} }}
  \stopStaff
}

%Clave de Sol en 2da.
claveDeSolEnSegunda = {
  \override Staff.StaffSymbol.stencil = #(color-staff-lines (rgb-color 0.8 0.8 0.8) (rgb-color 0.8 0.8 0.8) (rgb-color 0.8 0.8 0.8) (rgb-color 0.8 0.8 0.8) (rgb-color 0.8 0.8 0.8) red #f #f #f #f #f )
  \startStaff
  \set Staff.forceClef = ##t
  \set Staff.clefGlyph = #"clefs.G"
  \set Staff.clefPosition = #4
  \set Staff.middleCPosition = #0
  \set Staff.middleCClefPosition = #0
  s_\markup { \center-align \rotate #90 { \right-column {"Clave de Sol en 2ª" \italic "Soprano (moderna)"} }}
  \stopStaff
}

\header {
  tagline = ##f
}
\paper {
  indent = 0\mm
  %line-width = #(- line-width (* mm  3.000000) (* mm 1))
}
\score {
  \new Staff {
    \override Staff.Clef.full-size-change = ##t
    \clavesIniciales
    \espacioGris
    \claveDeFaEnCuarta
    \espacioGris
    \claveDeFaEnTercera
    \espacioGris
    \claveDeDoEnCuarta
    \espacioGris
    \claveDeDoEnTercera
    \espacioGris
    \claveDeDoEnSegunda
    \espacioGris
    \claveDeDoEnPrimera
    \espacioGris
    \claveDeSolEnSegunda
    \espacioGris
  }
  \layout {
    \context {
      \Staff
      \remove "Bar_engraver"
    }
    \context {
      \Score
      \remove "Bar_number_engraver"
    }
  }
  \midi{}
}