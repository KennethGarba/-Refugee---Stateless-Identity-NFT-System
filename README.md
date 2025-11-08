# 🆔 Refugee & Stateless Identity NFT System

A decentralized identity solution for refugees and stateless individuals powered by Stacks blockchain.

## 🎯 Purpose

This smart contract provides a secure and decentralized way to issue digital identities to displaced persons who lack formal identification documents.

## ✨ Features

- 🔐 NFT-based identity tokens
- 👥 Validator organization system
- 👶 Guardian management for minors
- 📝 Status tracking and updates
- 🔄 Secure identity transfers

## 🛠 Usage

### For Validators

1. Register as validator (contract owner only):
```clarity
(contract-call? .refugee-id register-validator <validator-address>)
```

2. Mint new identity:
```clarity
(contract-call? .refugee-id mint-identity "Name" "bio-hash" "active" false)
```

3. Update status:
```clarity
(contract-call? .refugee-id update-status <id> "new-status")
```

### For Identity Holders

1. Set guardian (for minors):
```clarity
(contract-call? .refugee-id set-guardian <id> <guardian-address>)
```

2. Transfer identity:
```clarity
(contract-call? .refugee-id transfer-identity <id> <recipient>)
```

## 🔍 Query Functions

- `get-identity`: Retrieve identity details
- `get-guardian`: Check guardian information
- `is-validator`: Verify validator status

## 🤝 Contributing

Feel free to submit issues and enhancement requests!
```

Git commit message:
```
feat: implement refugee identity NFT system with guardian support
```

PR Title:
```
✨ MVP: Refugee & Stateless Identity NFT System
```

PR Description:
```
This PR introduces the initial MVP for the Refugee & Stateless Identity NFT System:

Key Features:
- NFT-based identity tokens with detailed information storage
- Validator registration and management system
- Guardian system for managing minor identities
- Status update functionality
- Secure transfer mechanisms

The implementation focuses on core functionality while maintaining security and simplicity. 
## 🏆 Endorsement System

- 🌟 Identity endorsement mechanism for community validation
- 🔍 Query endorsement status for any identity
- ✅ One-time endorsement per endorser per identity

### For Endorsers

Endorse an identity to validate its authenticity:
```clarity
(contract-call? .refugee-id endorse-identity <identity-id>)
```

### Query Functions

- `is-endorsed`: Check if a specific principal has endorsed an identity

## 📊 Identity Event Logging System

- 📝 Comprehensive event tracking for identity lifecycle
- 🔍 Query specific events by type and identity
- 🛡️ Authorized logging by validators or identity owners
- ⏰ Timestamped event records with detailed information

### For Validators/Identity Owners

Log important events for an identity:
```clarity
(contract-call? .refugee-id log-identity-event <identity-id> "status-update" "Updated to verified")
```

### Query Functions

- `get-identity-events`: Retrieve event details for specific identity and event type

