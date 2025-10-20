
;; title: integration-with-iot
;; version:
;; summary:
;; description:

;; traits
;;

;; token definitions
;;

;; constants
;;

;; data vars
;;

;; data maps
;;

;; public functions
;;

;; read only functions
;;

;; private functions
;;

;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-authorized (err u101))
(define-constant err-invalid-shipment (err u102))
(define-constant err-condition-violation (err u103))

;; Define data variables
(define-data-var min-temperature int -5)  ;; Minimum allowed temperature in Celsius
(define-data-var max-temperature int 10)  ;; Maximum allowed temperature in Celsius

;; Define maps
(define-map shipments
  uint
  {
    owner: principal,
    current-location: (tuple (latitude int) (longitude int)),
    temperature: int,
    last-updated: uint,
    in-transit: bool
  }
)

(define-map authorized-devices
  principal
  bool
)

;; Define functions

;; Function to add a new shipment
(define-map shipments (uint) { 
  owner: principal, 
  current-location: (tuple (latitude int) (longitude int)), 
  temperature: int, 
  last-updated: uint, 
  in-transit: bool 
})

(define-constant err-owner-only (err u100))

(define-public (add-shipment (shipment-id uint) (initial-latitude int) (initial-longitude int))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-set shipments shipment-id {
      owner: contract-owner,
      current-location: (tuple (latitude initial-latitude) (longitude initial-longitude)),
      temperature: 0,
      last-updated: (block-height), ;; Correctly calling block-height as a function
      in-transit: true
    }))
  )
)

;; Function to authorize an IoT device
(define-public (authorize-device (device-principal principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-set authorized-devices device-principal true))
  )
)

;; Function to update shipment data from IoT device
(define-public (update-shipment-data (shipment-id uint) (new-latitude int) (new-longitude int) (new-temperature int))
  (let (
    (shipment (unwrap! (map-get? shipments shipment-id) err-invalid-shipment))
    (is-authorized (default-to false (map-get? authorized-devices tx-sender)))
  )
    (begin
      (asserts! is-authorized err-not-authorized)
      (asserts! (get in-transit shipment) err-invalid-shipment)
      
      ;; Check temperature conditions
      (asserts! (and (>= new-temperature (var-get min-temperature)) (<= new-temperature (var-get max-temperature))) err-condition-violation)
      
      ;; Update shipment data
      (map-set shipments shipment-id 
        (merge shipment {
          current-location: (tuple (latitude new-latitude) (longitude new-longitude)),
          temperature: new-temperature,
          last-updated: block-height
        })
      )
      
      (ok true)
    )
  )
)

;; Function to complete a shipment
(define-public (complete-shipment (shipment-id uint))
  (let (
    (shipment (unwrap! (map-get? shipments shipment-id) err-invalid-shipment))
  )
    (begin
      (asserts! (is-eq tx-sender (get owner shipment)) err-not-authorized)
      (asserts! (get in-transit shipment) err-invalid-shipment)
      
      ;; Mark shipment as completed
      (map-set shipments shipment-id 
        (merge shipment {
          in-transit: false
        })
      )
      
      (ok true)
    )
  )
)

;; Function to get shipment data
(define-read-only (get-shipment-data (shipment-id uint))
  (map-get? shipments shipment-id)
)

;; Function to update temperature thresholds
(define-public (update-temperature-thresholds (new-min int) (new-max int))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set min-temperature new-min)
    (var-set max-temperature new-max)
    (ok true)
  )
)