;; Demand Planner Verification Contract
;; Validates and manages demand planning professionals

(define-map planners
  { planner-id: principal }
  {
    name: (string-ascii 50),
    certification-level: uint,
    experience-years: uint,
    verified: bool,
    verification-date: uint
  }
)

(define-map planner-stats
  { planner-id: principal }
  {
    total-forecasts: uint,
    accurate-forecasts: uint,
    accuracy-rate: uint
  }
)

(define-data-var next-planner-id uint u1)

;; Register a new demand planner
(define-public (register-planner (name (string-ascii 50)) (certification-level uint) (experience-years uint))
  (let ((planner-id tx-sender))
    (asserts! (is-none (map-get? planners { planner-id: planner-id })) (err u100))
    (asserts! (> (len name) u0) (err u101))
    (asserts! (<= certification-level u5) (err u102))

    (map-set planners
      { planner-id: planner-id }
      {
        name: name,
        certification-level: certification-level,
        experience-years: experience-years,
        verified: false,
        verification-date: u0
      }
    )

    (map-set planner-stats
      { planner-id: planner-id }
      {
        total-forecasts: u0,
        accurate-forecasts: u0,
        accuracy-rate: u0
      }
    )

    (ok planner-id)
  )
)

;; Verify a planner (admin function)
(define-public (verify-planner (planner-id principal))
  (let ((planner-data (unwrap! (map-get? planners { planner-id: planner-id }) (err u200))))
    (map-set planners
      { planner-id: planner-id }
      (merge planner-data { verified: true, verification-date: block-height })
    )
    (ok true)
  )
)

;; Get planner information
(define-read-only (get-planner (planner-id principal))
  (map-get? planners { planner-id: planner-id })
)

;; Check if planner is verified
(define-read-only (is-verified (planner-id principal))
  (match (map-get? planners { planner-id: planner-id })
    planner-data (get verified planner-data)
    false
  )
)

;; Update planner statistics
(define-public (update-planner-stats (planner-id principal) (total-forecasts uint) (accurate-forecasts uint))
  (let ((accuracy-rate (if (> total-forecasts u0) (/ (* accurate-forecasts u100) total-forecasts) u0)))
    (map-set planner-stats
      { planner-id: planner-id }
      {
        total-forecasts: total-forecasts,
        accurate-forecasts: accurate-forecasts,
        accuracy-rate: accuracy-rate
      }
    )
    (ok accuracy-rate)
  )
)

;; Get planner statistics
(define-read-only (get-planner-stats (planner-id principal))
  (map-get? planner-stats { planner-id: planner-id })
)
