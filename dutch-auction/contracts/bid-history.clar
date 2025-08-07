;; bid-history.clar - Fixed version
(define-map bid-history
  {auction-id: uint, bidder: principal}
  {block: uint, price: uint, timestamp: uint})

(define-constant ERR_INVALID_BID (err u106))

;; Record a bid in the history
(define-public (record-bid (auction-id uint) (bidder principal) (price uint))
  (begin
    (asserts! (> price u0) ERR_INVALID_BID)
    
    (map-set bid-history 
      {auction-id: auction-id, bidder: bidder}
      {
        block: block-height, 
        price: price, 
        timestamp: (default-to u0 (get-block-info? time block-height))
      })
    
    (ok true)
  )
)

;; Get bid information
(define-read-only (get-bid (auction-id uint) (bidder principal))
  (map-get? bid-history {auction-id: auction-id, bidder: bidder}))

;; Get all bid data for debugging
(define-read-only (get-bid-count)
  (ok "Use specific auction-id and bidder to get bid data"))
