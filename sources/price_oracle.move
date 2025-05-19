// neo_oracle_move/sources/price_oracle.move
module neo_oracle_move::price_oracle {
    // Standard library string, usually needs explicit import
    use std::string::{Self, String};

    // sui::object, sui::tx_context, sui::transfer and their key types (UID, TxContext)
    // are often available by default or through the sui:: prelude in Move 2024.
    // We will rely on direct usage like object::new, UID, TxContext.

    /// Struct to store the aggregated price data for a specific trading pair.
    /// This object will be owned by the oracle.
    public struct PriceObject has key, store {
        id: UID, // Assuming UID is available directly or via sui::UID
        symbol: String,         
        price: u64,             
        timestamp_ms: u64,      
        decimals: u8,           
    }

    // === Errors ===
    // Define any potential errors here if needed in future, e.g.,
    // const EInvalidCaller: u64 = 0;
    // const EInvalidSymbol: u64 = 1;

    // === Public Functions ===

    /// Creates a new PriceObject for a given symbol and transfers it to the sender (oracle).
    /// This should be called by the oracle once for each symbol it intends to manage.
    public entry fun create_price_object(
        symbol_vec: vector<u8>,
        initial_price: u64,
        initial_timestamp_ms: u64,
        decimals_val: u8,
        ctx: &mut TxContext // Assuming TxContext is available
    ) {
        let price_obj = PriceObject {
            id: sui::object::new(ctx), // Using fully qualified path for clarity
            symbol: string::utf8(symbol_vec),
            price: initial_price,
            timestamp_ms: initial_timestamp_ms,
            decimals: decimals_val,
        };
        sui::transfer::transfer(price_obj, sui::tx_context::sender(ctx)); // Using fully qualified paths
    }

    /// Updates the price and timestamp for an existing PriceObject.
    /// This function must be called by the owner of the PriceObject (the oracle).
    public entry fun update_price(
        price_obj: &mut PriceObject,
        new_price: u64,
        new_timestamp_ms: u64,
        // Optional: We could re-verify symbol or decimals if needed, but for an owned object,
        // the oracle is trusted with its own objects.
        // _ctx: &TxContext // TxContext not strictly needed if only owner can call via &mut PriceObject
    ) {
        // No explicit check for tx_context::sender(ctx) == owner_of(price_obj) is needed here
        // because the `&mut PriceObject` argument ensures that only the owner (or someone the owner
        // has granted mutable access to, which isn't the case here for entry fun) can call this.
        price_obj.price = new_price;
        price_obj.timestamp_ms = new_timestamp_ms;
        // The symbol and decimals are set at creation and typically wouldn't change.
    }

    // === Getter Functions (View Functions) ===
    // These allow anyone to read the data from a PriceObject if they have its ID.

    public fun symbol(price_obj: &PriceObject): String {
        price_obj.symbol
    }

    public fun price(price_obj: &PriceObject): u64 {
        price_obj.price
    }

    public fun timestamp_ms(price_obj: &PriceObject): u64 {
        price_obj.timestamp_ms
    }

    public fun decimals(price_obj: &PriceObject): u8 {
        price_obj.decimals
    }

} 