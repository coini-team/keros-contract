## Commands

### Check it is all correct
clarinet check

### Run contract in devnet
```
clarinet console
```

### Generate deployment plan
```
clarinet deployment generate --testnet --low-cost
```

### Complete deployment
```
clarinet deployment apply -p deployments/default.testnet-plan.yaml
```
