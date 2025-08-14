
;; title: sBTC-DeFi-Integration-Toolkit
;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-authorized (err u101))
(define-constant err-insufficient-balance (err u102))
(define-constant err-invalid-amount (err u103))
(define-constant err-pool-not-found (err u104))
(define-constant err-expired (err u105))
(define-constant err-already-exists (err u106))
(define-constant err-invalid-params (err u107))
(define-constant err-pool-frozen (err u108))

;; Define data variables
(define-data-var protocol-fee uint u5) ;; 0.5% represented as 5/1000
(define-data-var fee-recipient principal contract-owner)
(define-data-var emergency-shutdown bool false)
(define-data-var total-locked-value uint u0)

;; Data structures
(define-map liquidity-pools
  { pool-id: uint }
  {
    sbtc-balance: uint,
    token-balance: uint,
    total-shares: uint,
    swap-fee: uint,
    is-active: bool,
    created-at: uint,
    last-updated: uint
  }
)

(define-map liquidity-providers
  { pool-id: uint, provider: principal }
  {
    shares: uint,
    sbtc-deposited: uint,
    token-deposited: uint,
    rewards-claimed: uint,
    last-deposit-height: uint
  }
)

(define-map yield-farms
  { farm-id: uint }
  {
    pool-id: uint,
    reward-token: principal,
    reward-per-block: uint,
    total-staked: uint,
    start-height: uint,
    end-height: uint,
    last-reward-calculation: uint,
    accumulated-rewards-per-share: uint,
    is-active: bool
  }
)

(define-map farmer-positions
  { farm-id: uint, farmer: principal }
  {
    staked-amount: uint,
    reward-debt: uint,
    unclaimed-rewards: uint,
    last-stake-height: uint
  }
)
