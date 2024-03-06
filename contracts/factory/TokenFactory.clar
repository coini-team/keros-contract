
;; A smart contract that allows users to custom base fungible token
;; Users can specify the symbol, name and quantity of the tokens they want to deploy
;; Users can transfer their tokens to other users


;; Define the contract variables
(define-data-var token-owner principal tx-sender) ;; The owner of the contract and the token
(define-data-var token-name (string-ascii 32) "") ;; The name of the token
(define-data-var token-symbol (string-ascii 32) "") ;; The symbol of the token
(define-data-var user-token-max-supply uint u0) ;; The maximum supply of the user's token
;; (define-data-var user-token-name principal tx-sender)
(define-constant price u1000000) ;; The price of minting one token in Stacks
(define-constant decimals u6) ;; The number of decimals of the token

;; Define the error codes
(define-constant ERR_FT_INITIALIZE_NAME_SHOULDNT_BY_EMPTY (err u100)) ;; The name of the token is invalid
(define-constant ERR_FT_INITIALIZE_SYMBOL_SHOULDNT_BY_EMPTY (err u101)) ;; The symbol of the token is invalid
(define-constant ERR_FT_INITIALIZE_SENDER_SHOULDNT_BY_WALLET (err u102)) ;; The wallet of the teken is invalid
(define-constant ERR_FT_INITIALIZE_AMOUNT_NOT_GREATER_THAN_ZERO (err u103)) ;;  The amount of the token is invalid
(define-constant ERR_FT_NOT_TOKEN_OWNER (err u104)) ;; The amount to mint is invalid
(define-constant ERR_FT_MINT_AMOUNT_NOT_GREATER_THAN_ZERO (err u105)) ;; The amount to mint is invalid
(define-constant ERR_FT_MINT_NOT_ENOUGH_TOKENS (err u106)) ;; The amount to mint is invalid
(define-constant ERR_FT_TRANSFER_SENDER_SHOULDNT_BY_RECIPIENT (err u107)) ;; The amount to transfer is invalid
(define-constant ERR_FT_TRANSFER_AMOUNT_NOT_ENOUGH_TOKENS (err u108)) ;; The amount to transfer is invalid


;;Define token base
(define-fungible-token BaseToken)

;; Customize token function
(define-public (initialize-user-token (wallet principal) (name (string-ascii 32)) (symbol (string-ascii 32)) (max-supply uint))
 (begin
    ;; Make sure the user has not defined a token before
    ;; (asserts! (is-eq (var-get user-token-name) u"") (err u"El usuario ya ha definido un token"))
    ;; Make sure wallet, name and symbol are not empty
    (asserts! (is-eq name "") ERR_FT_INITIALIZE_NAME_SHOULDNT_BY_EMPTY)
    (asserts! (is-eq symbol "") ERR_FT_INITIALIZE_SYMBOL_SHOULDNT_BY_EMPTY)
    ;; Make sure the sender is the wallet
    (asserts! (is-eq tx-sender wallet) ERR_FT_INITIALIZE_SENDER_SHOULDNT_BY_WALLET)
    ;; Make sure amount is grater than zero
    (asserts! (> max-supply u0) ERR_FT_INITIALIZE_AMOUNT_NOT_GREATER_THAN_ZERO)
    ;; Assign token details to user
    (var-set token-owner wallet)
    (var-set token-name name)
    (var-set token-symbol symbol)
    ;; Assign maximum supply to user
    (var-set user-token-max-supply max-supply)
    ;; Return a success message
    (ok "Custom token defined successfully")
 )
)

;; Define the mint function
(define-public (mint-user-token (recipient principal) (amount uint))
 (begin
    ;; Verify that the user has permissions to mint tokens
    (asserts! (is-eq (var-get token-owner) recipient) ERR_FT_NOT_TOKEN_OWNER)
    (asserts! (> amount u0) ERR_FT_MINT_AMOUNT_NOT_GREATER_THAN_ZERO)
    (asserts! (<= amount (var-get user-token-max-supply)) ERR_FT_MINT_NOT_ENOUGH_TOKENS)
    ;; Mint tokens
    (try! (ft-mint? BaseToken amount recipient))
    ;; Return a success message
    (ok "Successfully minted tokens")
 )
)

;; Define the transfer function
(define-public (transfer-user-token (amount uint) (sender principal) (recipient principal) )
 (begin
    ;; Verify that the sender is the owner of the token
    (asserts! (is-eq (var-get token-owner) sender) ERR_FT_NOT_TOKEN_OWNER)
    ;; Verify sender isn't recipient
    (asserts! (is-eq sender recipient) ERR_FT_TRANSFER_SENDER_SHOULDNT_BY_RECIPIENT)
    ;; Verify that the user has enough tokens to transfer
    (asserts! (<= amount (var-get user-token-max-supply)) ERR_FT_TRANSFER_AMOUNT_NOT_ENOUGH_TOKENS)
    ;; Transfer tokens
    (try! (ft-transfer? BaseToken amount sender recipient ))
    ;; Update maximum supply
    (var-set user-token-max-supply (- (var-get user-token-max-supply) amount))
    ;; Return a success message
    (ok "Tokens transferidos exitosamente")
 )
)