;; Contract name: deploy-fungible-token
;; Token name: MyToken
;; Token symbol: MTK

(define-constant contract-owner tx-sender)
(define-constant symbol "MYT")
(define-fungible-token my-token)

(define-public (mint-tokens (amount uint) (recipient principal))
  (begin
    ;; check that the amount is not 0
    ;; the recipient is the same as the sender
    ;; and only the contract owner can mint tokens
    (asserts! (and (> amount u0) (is-eq recipient tx-sender) (is-eq tx-sender)) (err u1))
    ;; mint the tokens and send them to the recipient
    (ft-mint? my-token amount recipient)
  )
)
