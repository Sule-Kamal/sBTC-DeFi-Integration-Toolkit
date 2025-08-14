
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

(define-map atomic-swaps
  { swap-id: (buff 32) }
  {
    initiator: principal,
    recipient: principal,
    sbtc-amount: uint,
    btc-amount: uint,
    hash-lock: (buff 32),
    time-lock: uint,
    status: (string-ascii 20),
    created-at: uint
  }
)

(define-map oracle-price-feeds
  { token: principal }
  {
    price-in-sats: uint,
    last-updated: uint,
    provider: principal
  }
)

(define-public (set-protocol-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (< new-fee u100) err-invalid-params) ;; Fee can't exceed 10%
    (ok (var-set protocol-fee new-fee))
  )
)

(define-public (set-fee-recipient (new-recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (var-set fee-recipient new-recipient))
  )
)

(define-public (toggle-emergency-shutdown)
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (var-set emergency-shutdown (not (var-get emergency-shutdown))))
  )
)

;; Additional error constants for new features
(define-constant err-proposal-not-found (err u109))
(define-constant err-voting-ended (err u110))
(define-constant err-already-voted (err u111))
(define-constant err-insufficient-voting-power (err u112))
(define-constant err-loan-not-found (err u113))
(define-constant err-loan-not-due (err u114))
(define-constant err-insufficient-collateral (err u115))
(define-constant err-vault-not-found (err u116))
(define-constant err-invalid-signature (err u117))
(define-constant err-nft-not-found (err u118))
(define-constant err-auction-ended (err u119))
(define-constant err-invalid-bid (err u120))

;; Additional data variables for new features
(define-data-var next-proposal-id uint u1)
(define-data-var next-loan-id uint u1)
(define-data-var next-vault-id uint u1)
(define-data-var next-auction-id uint u1)
(define-data-var governance-token-supply uint u1000000)
(define-data-var min-proposal-threshold uint u10000)
(define-data-var voting-period uint u1440) ;; 1440 blocks (~24 hours)

;; GOVERNANCE SYSTEM
(define-map governance-proposals
  { proposal-id: uint }
  {
    proposer: principal,
    title: (string-ascii 100),
    description: (string-ascii 500),
    proposal-type: (string-ascii 20),
    target-value: uint,
    votes-for: uint,
    votes-against: uint,
    status: (string-ascii 20),
    created-at: uint,
    voting-ends-at: uint,
    execution-delay: uint
  }
)

(define-map governance-votes
  { proposal-id: uint, voter: principal }
  {
    vote-power: uint,
    vote-direction: bool, ;; true = for, false = against
    voted-at: uint
  }
)

(define-map governance-tokens
  { holder: principal }
  {
    balance: uint,
    delegated-to: (optional principal),
    voting-power: uint,
    last-delegation-change: uint
  }
)

;; LENDING/BORROWING PROTOCOL
(define-map lending-pools
  { token: principal }
  {
    total-supplied: uint,
    total-borrowed: uint,
    supply-rate: uint,
    borrow-rate: uint,
    utilization-rate: uint,
    reserve-factor: uint,
    last-updated: uint,
    is-active: bool
  }
)

(define-map user-supplies
  { token: principal, user: principal }
  {
    supplied-amount: uint,
    supply-index: uint,
    last-updated: uint
  }
)

(define-map user-borrows
  { token: principal, user: principal }
  {
    borrowed-amount: uint,
    borrow-index: uint,
    collateral-factor: uint,
    last-updated: uint
  }
)