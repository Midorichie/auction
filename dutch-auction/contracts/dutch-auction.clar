(define-data-var auction-owner principal tx-sender)
(define-data-var start-block uint u0)
(define-data-var end-block uint u0)
(define-data-var initial-price uint u0)
(define-data-var reserve-price uint u0)
(define-data-var decrement uint u0)
(define-data-var buyer (optional principal) none)
(define-data-var item-name (string-ascii 50) "")

(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_ALREADY_SOLD (err u101))
(define-constant ERR_TOO_EARLY (err u102))
(define-constant ERR_TOO_LATE (err u103))
(define-constant ERR_PRICE_TOO_LOW (err u104))

(define-public (create-auction (item (string-ascii 50)) (start uint) (end uint) (initial uint) (reserve uint) (decr uint))
    (begin
        (if (is-eq tx-sender (var-get auction-owner))
            (begin
                (var-set start-block start)
                (var-set end-block end)
                (var-set initial-price initial)
                (var-set reserve-price reserve)
                (var-set decrement decr)
                (var-set item-name item)
                (ok true)
            )
            ERR_UNAUTHORIZED
        )
    )
)

(define-read-only (get-current-price)
    (let
        (
            (block-height block-height)
            (start (var-get start-block))
            (initial (var-get initial-price))
            (reserve (var-get reserve-price))
            (decr (var-get decrement))
        )
        (if (< block-height start)
            ERR_TOO_EARLY
            (let
                (
                    (elapsed (- block-height start))
                    (price (if (> initial (+ reserve (* elapsed decr)))
                             (- initial (* elapsed decr))
                             reserve))
                )
                (ok price)
            )
        )
    )
)

(define-public (buy)
    (begin
        (if (is-some (var-get buyer))
            ERR_ALREADY_SOLD
            (let
                (
                    (current-block block-height)
                    (start (var-get start-block))
                    (end (var-get end-block))
                )
                (if (< current-block start)
                    ERR_TOO_EARLY
                    (if (> current-block end)
                        ERR_TOO_LATE
                        (match (get-current-price)
                            price
                            (if (>= (to-uint (stx-get-transfer-amount tx-sender)) price)
                                (begin
                                    (var-set buyer (some tx-sender))
                                    (ok true)
                                )
                                ERR_PRICE_TOO_LOW
                            )
                        )
                    )
                )
            )
        )
    )
)
