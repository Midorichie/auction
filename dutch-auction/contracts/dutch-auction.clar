;; dutch-auction.clar - Fixed version
(define-data-var auction-owner principal tx-sender)
(define-data-var start-block uint u0)
(define-data-var end-block uint u0)
(define-data-var initial-price uint u0)
(define-data-var reserve-price uint u0)
(define-data-var decrement uint u0)
(define-data-var buyer (optional principal) none)
(define-data-var item-name (string-ascii 50) "")

;; Error constants
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_ALREADY_SOLD (err u101))
(define-constant ERR_TOO_EARLY (err u102))
(define-constant ERR_TOO_LATE (err u103))
(define-constant ERR_PRICE_TOO_LOW (err u104))
(define-constant ERR_INVALID_INPUT (err u105))
(define-constant ERR_TRANSFER_FAILED (err u106))

;; Create a new auction
(define-public (create-auction 
  (item (string-ascii 50)) 
  (start uint) 
  (end uint) 
  (initial uint) 
  (reserve uint) 
  (decr uint))
  (begin
    (asserts! (is-eq tx-sender (var-get auction-owner)) ERR_UNAUTHORIZED)
    (asserts! (< reserve initial) ERR_INVALID_INPUT)
    (asserts! (< start end) ERR_INVALID_INPUT)
    (asserts! (> decr u0) ERR_INVALID_INPUT)
    
    (var-set start-block start)
    (var-set end-block end)
    (var-set initial-price initial)
    (var-set reserve-price reserve)
    (var-set decrement decr)
    (var-set item-name item)
    (var-set buyer none)
    
    (ok true)
))

;; Get current price based on block height
(define-read-only (get-current-price)
  (let
    (
      (current-block block-height)
      (start (var-get start-block))
      (initial (var-get initial-price))
      (reserve (var-get reserve-price))
      (decr (var-get decrement))
    )
    (if (< current-block start)
        ERR_TOO_EARLY
        (if (> current-block (var-get end-block))
            ERR_TOO_LATE
            (let
              (
                (elapsed (- current-block start))
                (price-reduction (* elapsed decr))
                (calculated-price (if (> initial price-reduction)
                                    (- initial price-reduction)
                                    reserve))
              )
              (ok calculated-price)
            )
        )
    )
))

;; Buy the item at current price
(define-public (buy (payment uint))
  (begin
    (asserts! (is-none (var-get buyer)) ERR_ALREADY_SOLD)
    
    (let
      (
        (current-block block-height)
        (start (var-get start-block))
        (end (var-get end-block))
        (owner (var-get auction-owner))
        (price (try! (get-current-price)))
      )
      (asserts! (>= current-block start) ERR_TOO_EARLY)
      (asserts! (<= current-block end) ERR_TOO_LATE)
      (asserts! (>= payment price) ERR_PRICE_TOO_LOW)
      
      ;; Transfer STX from buyer to seller
      (match (stx-transfer? payment tx-sender owner)
        success-transfer
        (begin
          (var-set buyer (some tx-sender))
          (ok price)
        )
        error-transfer ERR_TRANSFER_FAILED
      )
    )
))

;; Read-only functions
(define-read-only (get-auction-info)
  (ok {
    owner: (var-get auction-owner),
    item-name: (var-get item-name),
    start-block: (var-get start-block),
    end-block: (var-get end-block),
    initial-price: (var-get initial-price),
    reserve-price: (var-get reserve-price),
    decrement: (var-get decrement),
    buyer: (var-get buyer),
    current-block: block-height
  }))

(define-read-only (is-auction-active)
  (and 
    (>= block-height (var-get start-block))
    (<= block-height (var-get end-block))
    (is-none (var-get buyer))))
