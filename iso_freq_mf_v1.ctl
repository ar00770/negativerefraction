;Calculates the EFS contours for a triangular lattice
;Parameters and Geometry
;define GaAs index
(define-param index_GaAs 3.6)
(define-param epsilon_GaAs (* index_GaAs index_GaAs))
(define-param epsilon_air 1)
(set! resolution 32)
;setup the number of bands
(set! num-bands 8)
; setup the background material to air
(set! default-material (make dielectric (epsilon epsilon_air)))
;setup a triangular lattice
(set! geometry-lattice (make lattice (size 1 1 no-size)
                         (basis1 (/ (sqrt 3) 2) 0.5)
                         (basis2 (/ (sqrt 3) 2) -0.5)))
;setup a triangular lattice of circular rods of GaAs in air background
(set! geometry (list (make cylinder
                       (center 0 0 0) (radius 0.35) (height infinity)
                       (material (make dielectric (epsilon epsilon_GaAs))))))
;-------------------------------------------------
;-------------------------------------------------
; Define high symmetry points for hexagonal lattice
;-------------------------------------------------
;-------------------------------------------------
; here we define the corners of the hexagon and calculate 
; the band structure for k-vectors inside it
; in principle, we should use only the irr Brillouin zone,
; but computation is relatively quick
(define Gamma (vector3 0 0 0 ))
(define M  (vector3  0 0.5 0))
(define K0  (vector3 (/ -3) (/ 3) 0));
; If needed we can make K a bit longer 
; as interpolation has issues around the BZ edge
;;(define scale 1)
;;(define K (vector3* K0 scale))
(define K K0)
;;first corner FBZ hexagon in cartesian coordinates
(define KC1 (reciprocal->cartesian K))
;;subsequent corners of the FBZ hexagon
(define theta (deg->rad 60))
(define axis  (vector3 0 0 1))
;;rotate the first corner vector by 60 deg about the z-axis
(define KC2  (rotate-vector3 axis theta KC1))
;;rotate the second corner vector by 60 deg about the z-axis
(define KC3  (rotate-vector3 axis theta KC2))
(define KC4  (rotate-vector3 axis theta KC3))
(define KC5  (rotate-vector3 axis theta KC4))
(define KC6  (rotate-vector3 axis theta KC5))
;; the corners of the FBZ hexagon in rec coordinates
(define K1  (cartesian->reciprocal  KC1))
(define K2  (cartesian->reciprocal  KC2)) 
(define K3  (cartesian->reciprocal  KC3)) 
(define K4  (cartesian->reciprocal  KC4))
(define K5  (cartesian->reciprocal  KC5))
(define K6  (cartesian->reciprocal  KC6))
;define the number of k-points for interpolation
(define-param N_Points 400)

;
; define min and max functions (some trouble with the libctl ones)
(define (minim lst)
    (cond ((null? (cdr lst)) (car lst))
          ((< (car lst) (minim (cdr lst))) (car lst))
          (else (minim (cdr lst)))) )

(define (maxim lst)
    (cond ((null? (cdr lst)) (car lst))
          ((> (car lst) (maxim (cdr lst))) (car lst))
          (else (maxim (cdr lst)))) )
;; Setup the corners of the recatangle containing the hexagon
(define K-list (list KC1 KC2 KC3 KC4 KC5 KC6))
(define Kx-list (map vector3-x K-list))
(define Ky-list (map vector3-y K-list))
(define kx-min (minim Kx-list))
(define kx-max (maxim Kx-list))
(define ky-min (minim Ky-list))
(define ky-max (maxim Ky-list))
;; Setup a rectangular grid in the cartesian space 
;; on the rectangle containing the FBZ hexagon
;; some points will be outside the FBZ
;; to recycle some code we define it as a function
(define (kgrid kx-min kx-max ky-min ky-max nkx nky)
   (map (lambda (kx)
          (interpolate nky (list (vector3 kx ky-min) (vector3 kx ky-max)))
        )
          (interpolate nkx (list kx-min kx-max))
   )
)
;; here is the grid
(define nkx N_Points)
(define nky N_Points)
(define k-grid-cartesian0 (kgrid kx-min kx-max ky-min ky-max nkx nky))
;;flatten the list of lists in the k-grid to a single list
(define k-grid-cartesian (apply append k-grid-cartesian0))

;;convert the grid to a list of k-points in reciprocal space
(define k-grid-reciprocal1 (map cartesian->reciprocal k-grid-cartesian))
;; As mentioned the k-grid extends outside the FBZ.
;; here we map it back into the FBZ
(define k-grid-reciprocal (map first-brillouin-zone k-grid-reciprocal1))

;set the k-points to the grid created
(set! k-points k-grid-reciprocal)
;run the TE band structure
(run-te display-group-velocities)
;; print the hexagons coreners for import/testing in matlab
(print "KC1" KC1 "\n")
(print "KC2" KC2 "\n")
(print "KC3" KC3 "\n")
(print "KC4" KC4 "\n")
(print "KC5" KC5 "\n")
(print "KC6" KC6 "\n")
