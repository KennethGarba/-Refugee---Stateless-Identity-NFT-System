(define-non-fungible-token refugee-id uint)

(define-constant contract-owner tx-sender)
(define-constant err-not-authorized (err u100))
(define-constant err-invalid-id (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-guardian-required (err u103))
(define-constant err-identity-expired (err u104))
(define-constant err-identity-revoked (err u105))

(define-data-var last-id uint u0)
(define-map validators principal bool)
(define-map identity-details 
    uint 
    {name: (string-ascii 50),
     bio-hash: (string-ascii 64),
     status: (string-ascii 20),
     created-at: uint,
     expires-at: uint,
     issuer: principal})

(define-map guardian-details
     uint
     {guardian: principal,
      minor: bool})

(define-map revoked-identities uint bool)

(define-read-only (get-last-id)
    (var-get last-id))

(define-read-only (is-validator (address principal))
    (default-to false (map-get? validators address)))

(define-read-only (get-identity (id uint))
    (map-get? identity-details id))

(define-read-only (get-guardian (id uint))
     (map-get? guardian-details id))

(define-read-only (is-identity-revoked (id uint))
     (default-to false (map-get? revoked-identities id)))

(define-read-only (is-identity-valid (id uint))
     (match (map-get? identity-details id)
         some-details (and (>= (get expires-at some-details) burn-block-height) (is-none (map-get? revoked-identities id)))
         false))

(define-public (register-validator (validator-address principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-not-authorized)
        (ok (map-set validators validator-address true))))

(define-public (remove-validator (validator-address principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-not-authorized)
        (ok (map-delete validators validator-address))))

(define-public (mint-identity 
    (name (string-ascii 50))
    (bio-hash (string-ascii 64))
    (status (string-ascii 20))
    (validity-period uint)
    (is-minor bool))
    (let ((new-id (+ (var-get last-id) u1)))
        (asserts! (is-validator tx-sender) err-not-authorized)
        (try! (nft-mint? refugee-id new-id tx-sender))
        (map-set identity-details new-id
            {name: name,
             bio-hash: bio-hash,
             status: status,
             created-at: burn-block-height,
             expires-at: (+ burn-block-height validity-period),
             issuer: tx-sender})
        (var-set last-id new-id)
        (ok new-id)))
(define-public (set-guardian 
    (id uint)
    (guardian-address principal))
    (let ((identity (nft-get-owner? refugee-id id)))
        (asserts! (is-some identity) err-invalid-id)
        (asserts! (is-eq (some tx-sender) identity) err-not-authorized)
        (ok (map-set guardian-details id
            {guardian: guardian-address,
             minor: true}))))

(define-public (update-status
    (id uint)
    (new-status (string-ascii 20)))
    (let ((identity (nft-get-owner? refugee-id id)))
        (asserts! (is-validator tx-sender) err-not-authorized)
        (asserts! (is-some identity) err-invalid-id)
        (let ((details (unwrap! (map-get? identity-details id) err-invalid-id)))
            (ok (map-set identity-details id
                {name: (get name details),
                 bio-hash: (get bio-hash details),
                 status: new-status,
                 created-at: (get created-at details),
                 expires-at: (get expires-at details),
                 issuer: (get issuer details)})))))

(define-public (renew-identity
     (id uint)
     (new-validity-period uint))
     (let ((identity (nft-get-owner? refugee-id id)))
         (asserts! (is-validator tx-sender) err-not-authorized)
         (asserts! (is-some identity) err-invalid-id)
         (let ((details (unwrap! (map-get? identity-details id) err-invalid-id)))
             (ok (map-set identity-details id
                 {name: (get name details),
                  bio-hash: (get bio-hash details),
                  status: (get status details),
                  created-at: (get created-at details),
                  expires-at: (+ burn-block-height new-validity-period),
                  issuer: (get issuer details)})))))

(define-public (revoke-identity (id uint))
     (begin
         (asserts! (is-validator tx-sender) err-not-authorized)
         (asserts! (is-some (map-get? identity-details id)) err-invalid-id)
         (ok (map-set revoked-identities id true))))

(define-public (transfer-identity
    (id uint)
    (recipient principal))
    (let ((guardian (map-get? guardian-details id)))
        (if (is-some guardian)
            (asserts! (is-eq tx-sender (get guardian (unwrap-panic guardian))) err-not-authorized)
            (asserts! (is-eq (some tx-sender) (nft-get-owner? refugee-id id)) err-not-authorized))
        (nft-transfer? refugee-id id tx-sender recipient)))