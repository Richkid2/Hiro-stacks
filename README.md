# IoT Shipment Tracking Smart Contract

A Clarity smart contract for tracking shipments with integrated IoT device monitoring on the Stacks blockchain. This contract enables real-time tracking of shipment location and temperature conditions with automated validation.

## Overview

This smart contract provides a decentralized solution for supply chain management, allowing authorized IoT devices to update shipment data while enforcing temperature compliance rules. It's particularly useful for cold chain logistics where temperature monitoring is critical.

## Features

- **Shipment Management**: Create and track multiple shipments with unique IDs
- **IoT Device Authorization**: Secure authorization system for IoT devices
- **Real-time Updates**: Location (GPS coordinates) and temperature tracking
- **Temperature Monitoring**: Automated validation against configurable thresholds
- **Condition Violation Detection**: Immediate alerts when temperature limits are exceeded
- **Shipment Lifecycle**: Track shipments from creation to completion

## Constants

- `contract-owner`: The principal who deployed the contract
- `err-owner-only` (u100): Error returned when non-owner attempts owner-only functions
- `err-not-authorized` (u101): Error for unauthorized device access
- `err-invalid-shipment` (u102): Error for invalid or non-existent shipment
- `err-condition-violation` (u103): Error when temperature is outside allowed range

## Data Structures

### Data Variables

- `min-temperature`: Minimum allowed temperature (default: -5°C)
- `max-temperature`: Maximum allowed temperature (default: 10°C)

### Maps

**shipments**
```clarity
{
  owner: principal,
  current-location: {latitude: int, longitude: int},
  temperature: int,
  last-updated: uint,
  in-transit: bool
}
```

**authorized-devices**
```clarity
principal -> bool
```

## Public Functions

### `add-shipment`

Creates a new shipment with an initial location.

```clarity
(add-shipment (shipment-id uint) (initial-latitude int) (initial-longitude int))
```

**Parameters:**
- `shipment-id`: Unique identifier for the shipment
- `initial-latitude`: Starting latitude coordinate
- `initial-longitude`: Starting longitude coordinate

**Returns:** `(ok true)` on success

**Authorization:** Contract owner only

### `authorize-device`

Authorizes an IoT device to update shipment data.

```clarity
(authorize-device (device-principal principal))
```

**Parameters:**
- `device-principal`: The principal address of the IoT device

**Returns:** `(ok true)` on success

**Authorization:** Contract owner only

### `update-shipment-data`

Updates shipment location and temperature from an authorized IoT device.

```clarity
(update-shipment-data (shipment-id uint) (new-latitude int) (new-longitude int) (new-temperature int))
```

**Parameters:**
- `shipment-id`: ID of the shipment to update
- `new-latitude`: Current latitude coordinate
- `new-longitude`: Current longitude coordinate
- `new-temperature`: Current temperature in Celsius

**Returns:** `(ok true)` on success, error if temperature violates thresholds

**Authorization:** Authorized devices only

**Validations:**
- Device must be authorized
- Shipment must be in transit
- Temperature must be within min/max thresholds

### `complete-shipment`

Marks a shipment as completed (no longer in transit).

```clarity
(complete-shipment (shipment-id uint))
```

**Parameters:**
- `shipment-id`: ID of the shipment to complete

**Returns:** `(ok true)` on success

**Authorization:** Shipment owner only

### `update-temperature-thresholds`

Updates the acceptable temperature range for all shipments.

```clarity
(update-temperature-thresholds (new-min int) (new-max int))
```

**Parameters:**
- `new-min`: New minimum temperature threshold (Celsius)
- `new-max`: New maximum temperature threshold (Celsius)

**Returns:** `(ok true)` on success

**Authorization:** Contract owner only

## Read-Only Functions

### `get-shipment-data`

Retrieves all data for a specific shipment.

```clarity
(get-shipment-data (shipment-id uint))
```

**Parameters:**
- `shipment-id`: ID of the shipment to query

**Returns:** Shipment data or `none` if shipment doesn't exist

## Usage Example

### 1. Deploy Contract
Deploy the contract to Stacks blockchain. The deployer becomes the contract owner.

### 2. Create a Shipment
```clarity
(contract-call? .integration-with-iot add-shipment u1 404000 -740000)
```

### 3. Authorize IoT Device
```clarity
(contract-call? .integration-with-iot authorize-device 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

### 4. Update from IoT Device
```clarity
(contract-call? .integration-with-iot update-shipment-data u1 404500 -739500 5)
```

### 5. Query Shipment Data
```clarity
(contract-call? .integration-with-iot get-shipment-data u1)
```

### 6. Complete Shipment
```clarity
(contract-call? .integration-with-iot complete-shipment u1)
```

## Error Handling

The contract returns descriptive errors for common failure cases:

- **u100**: Only the contract owner can perform this action
- **u101**: Device is not authorized or user is not shipment owner
- **u102**: Shipment ID is invalid or already completed
- **u103**: Temperature reading violates configured thresholds

## Security Considerations

- Only the contract owner can create shipments and authorize devices
- IoT devices must be explicitly authorized before updating shipment data
- Temperature violations prevent data updates, ensuring compliance
- Shipment owners maintain exclusive control over completion
- All updates are timestamped with block height for audit trails

## Use Cases

- **Cold Chain Logistics**: Monitor refrigerated goods during transport
- **Pharmaceutical Distribution**: Ensure temperature-sensitive medications remain viable
- **Food Supply Chain**: Track perishable goods with temperature compliance
- **Asset Tracking**: Monitor high-value goods with location verification

## License

This smart contract is provided as-is for educational and commercial use.

## Contributing

Contributions, issues, and feature requests are welcome. Please ensure all changes maintain backward compatibility and include appropriate test coverage.
