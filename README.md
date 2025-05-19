# Neo Oracle Move Contract

This repository contains the Sui Move contract for the Neo Oracle MVP.

## Modules

*   `price_oracle`: Defines the `PriceObject` for storing aggregated price data on-chain and functions to manage it.

## Usage

This contract is intended to be deployed to the Sui blockchain. The oracle service (running off-chain) will call this contract to:

1.  Create `PriceObject`s for each supported trading pair.
2.  Update these `PriceObject`s with the latest aggregated prices.

## Building

```bash
sui move build
```

## Testing

```bash
sui move test
```

## Publishing

Ensure your Sui CLI is configured for the desired network and address.

```bash
sui client publish --gas-budget <your_gas_budget>
``` 