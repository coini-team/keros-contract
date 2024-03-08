;; ;; Contract name: keros.clar
;; ;; Token name: keros
;; ;; Token symbol: KER

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant contract-owner tx-sender)
(define-constant token-owner tx-sender)
(define-constant price u1000000)

(define-constant ERR_OWNER_ONLY (err u100))
(define-constant ERR_NOT_TOKEN_OWNER (err u101))
(define-constant ERR_TOKEN_MINT (err u102))
(define-constant ERR_SANDER_IS_RECIPIENT (err u103))
(define-constant ERR_INSUFFICIENT_BALANCE (err u104))
(define-constant ERR_MINT_AMOUNT (err u105))
(define-constant ERR_INSUFFICIENT_STX (err u106))

(define-fungible-token keros)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq tx-sender sender) ERR_OWNER_ONLY)
        (asserts! (not (is-eq tx-sender recipient)) ERR_SANDER_IS_RECIPIENT)
        (asserts! (<= amount (ft-get-balance keros sender)) ERR_INSUFFICIENT_BALANCE)
        (try! (ft-transfer? keros amount sender recipient))
        (match memo to-print (print to-print) 0x)
        (ok true)
    )
)

(define-read-only (get-name)
    (ok "keros")
)

(define-read-only (get-symbol)
    (ok "KRS")
)

(define-read-only (get-decimals)
    (ok u6)
)

(define-read-only (get-balance (who principal))
    (ok (ft-get-balance keros who))
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply keros))
)


(define-read-only (get-token-uri)
    (ok none)
)


(define-public (mint (amount uint) (recipient principal))
    (begin
        ;; (asserts! (not (is-eq tx-sender contract-owner)) ERR_OWNER_ONLY)
        (asserts! (not (is-eq tx-sender recipient)) ERR_OWNER_ONLY)
        (asserts! (>= amount u1) ERR_MINT_AMOUNT)
        (try! (ft-mint? keros amount recipient))
        (ok "Mint Succeful")
    )
)

(define-public (buy-token (amount uint) (recipient principal))
    (begin
        (asserts! (not (is-eq tx-sender recipient)) ERR_SANDER_IS_RECIPIENT)
        (asserts! (<= amount (ft-get-balance keros token-owner)) ERR_INSUFFICIENT_BALANCE)
        (asserts! (>= (stx-get-balance recipient) (* amount price)) ERR_INSUFFICIENT_STX)
        (try! (ft-transfer? keros amount token-owner recipient))
        (try! (stx-transfer? (* amount price) recipient token-owner))
        (ok "Succesfull Transaction")
    )
)