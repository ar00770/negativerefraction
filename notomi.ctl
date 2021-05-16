; set up the background material to air
(set! default-material (make dielectric (epsilon 1)))
;; set the number of bands to be included
(set! num-bands 8)
;;set the k-space path along which the band structure is calculated
(define Gamma (vector3 0 0 0))
(define X (vector3 -0.33 0.33 0))
(define M (vector3 0 0.5 0))
(set! k-points (list X M Gamma X))
(set! k-points (interpolate 4 k-points))
;; make the dielectric structure
(set! geometry (list(make cylinder (center 0 0 0) (radius 0.35) (height
infinity) (material (make dielectric (epsilon 12.96))))))
;; set the lattice geometry hexagonal lattice
(set! geometry-lattice (make lattice (size 1 1 no-size)(basis1 0.866 0.5)(basis2
0.866 -0.5)))
;; set the resolution of the calculation
(set! resolution 32)
;;run the computation and output the Ez field at the X and M points
(run-tm (output-at-kpoint X output-efield-z) (output-at-kpoint M output-efieldz) )
(run-te (output-at-kpoint X output-efield-z) (output-at-kpoint M output-efieldz) )
