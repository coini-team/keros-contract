
;; NFTFactory
;; This contract is a simple NFT contract that allows the minting of NFTs and the transfer of NFTs.

;; Implements.
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Token
(define-non-fungible-token amazing-nft uint)

;; Variables.
(define-data-var last-token-id uint u0)
(define-data-var base-uri (string-ascii 100) "OSADUHIQEWIH19O1289EXH12EH8C1")

;; Constants.
(define-constant MINT_PRICE u5000000)
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_OWNER_ONLY (err u100))
(define-constant ERR_NOT_TOKEN_OWNER (err u101))


;; Get the last token id.
(define-read-only (get-last-token-id)
    (ok (var-get last-token-id))
)

;; Get the base uri.
(define-read-only (get-token-uri (token-id uint))
    (ok (some (var-get base-uri)))
)

;; Get the owner of the token.
(define-read-only (get-owner (token-id uint))
    (ok (nft-get-owner? amazing-nft token-id))
)

;; Transfer the token.
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender sender) ERR_NOT_TOKEN_OWNER)
        (nft-transfer? amazing-nft token-id sender recipient)
    )
)

;; Mint a new token.
(define-public (mint)
  (let 
    (
      (id (+ (var-get last-token-id) u1))
    )
    (try! (stx-transfer? MINT_PRICE tx-sender CONTRACT_OWNER))
    (try! (nft-mint? amazing-nft id tx-sender))
    (var-set last-token-id id)
    (ok id)
  )
)