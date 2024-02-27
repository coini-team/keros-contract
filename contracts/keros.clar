;; ;; Contract name: deploy-fungible-token
;; ;; Token name: keros
;; ;; Token symbol: KER

(define-data-var token-owner principal tx-sender) ;; token woner
(define-data-var buy-date uint u0) ;; Token deploy date
(define-data-var price uint u100) ;; price on microSTX
(define-constant symbol "KER") ;; token symbol
(define-fungible-token keros) ;; token name
(define-constant ERR_FT_TRANSFER_AMOUNT (err u100)) ;; transfer error
(define-constant ERR_FT_DEPLOY (err u101)) ;; deploy error
(define-constant ERR_TIME_BLOCK (err u102)) ;; block time error
(define-constant ERR_FT_DEPLOY_AMOAUNT (err u103)) ;; transfer error
(define-constant ERR_FT_TRANSFER (err u104)) ;; transfer error
(define-constant ERR_SET_LAPS_TIME (err u105)) ;; transfer error 
(define-constant ERR_SET_NEW_PRICE (err u106)) ;; transfer error 

(define-private (get-buy-date)
  (let ((block-time (get-block-info? time u0))) ;; u0 is the today block
    (if (is-some block-time)
      (ok (some block-time)) ;; return date & time in UNIX format
      ERR_TIME_BLOCK
    )
  )
)

;; function to mint a token
(define-public (mint-tokens (amount uint) (recipient principal))
  (begin
    ;; check that the amount is not 0
    ;; the recipient is the same as the sender
    (asserts! (and (> amount u0) (is-eq recipient tx-sender)) ERR_FT_DEPLOY_AMOAUNT)
    ;; mint the tokens and send them to the recipient
    (unwrap! (ft-mint? keros amount recipient) ERR_FT_DEPLOY)
    ;; set a token owner 
    (var-set token-owner tx-sender)
    ;; Success message
    (ok "Success")
  )
)

(define-public (buy-token (amount uint))
  (begin
    ;; calculate the total cost in microSTX
    (let ((cost (* amount (var-get price))))
      ;; check that the sender has enough STX to pay
      (asserts! (>= (stx-get-balance tx-sender) cost) ERR_FT_TRANSFER_AMOUNT)
      ;; transfer the STX from the sender to the token owner
      (try! (stx-transfer? cost tx-sender (var-get token-owner)))
      ;; mint the tokens and send them to the sender
      (unwrap! (ft-mint? keros amount tx-sender) ERR_FT_DEPLOY)
      ;;Set deploy data
      (var-set buy-date (unwrap! (unwrap! (unwrap! (get-buy-date) ERR_TIME_BLOCK ) ERR_TIME_BLOCK ) ERR_TIME_BLOCK ))
      ;; success message
      (ok "Success")
    )
  )
)

;; function to get the current price of the token
(define-read-only (get-price)
  (let ((block-time (get-block-info? time u0))) ;; u0 is the current block
    (if (is-some block-time)
      (let ((deploy-time (var-get buy-date))) ;; get the deploy date
        (let ((elapsed-time (- (unwrap! block-time ERR_SET_LAPS_TIME) deploy-time))) ;; calculate the elapsed time in seconds
          (let ((elapsed-months (- (/ elapsed-time (* u30 u24 u60 u60)) (mod (/ elapsed-time (* u30 u24 u60 u60)) u1))));; calculate the elapsed months
            (let ((increase-rate (+ u1 (/ (* u5 elapsed-months) u10000)))) ;; calculate the increase rate
              (ok (* (var-get price) increase-rate)) ;; return the current price
            )
          )
        )
      )
      ERR_SET_NEW_PRICE
    )
  )
)

;; function to update the price of the token
(define-private (update-price)
  (begin
    ;; check that the sender is the token owner
    (asserts! (is-eq tx-sender (var-get token-owner)) ERR_FT_TRANSFER)
    ;; get the current price
    (let ((current-price (unwrap! (get-price) ERR_TIME_BLOCK)))
      ;; set the price to the current price
      (var-set price current-price)
      ;; success message
      (ok "Success")
    )
  )
)