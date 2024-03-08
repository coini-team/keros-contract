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


How to interact with local Clarinet instance

Launch Clarinet Console:

```
clarinet console
```

Select contract and call the Function:

```
(contract-call? .hello-world echo-number)
```

```
(contract-call? .<contract_name> <function_name>)
```

(contract-call? .CustomFungibleToken mint u100 tx-sender)
(contract-call? .CustomFungibleToken get-balance tx-sender)
