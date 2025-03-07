# Task Manager - Solidity Smart Contract

## Overview

Task Manager is a smart contract written in Solidity that allows the owner to create, update, delete, and retrieve tasks. It is optimized for gas efficiency and includes event logging for transparency.

## Features

- **Create Task**: Allows the contract owner to create a task with a title and description.
- **Update Task**: Updates the title, description, or completion status of an existing task.
- **Mark Task as Completed**: Marks an existing task as completed.
- **Delete Task**: Removes a task from the contract storage.
- **Retrieve a Task**: Fetches details of a specific task.
- **Retrieve All Tasks**: Returns all existing tasks.

## Technologies Used

- Solidity `^0.8.28`
- OpenZeppelin's `Ownable` contract for ownership management
- Foundry for development, testing, and deployment

---

## Setup & Installation

### Prerequisites

- Install **Foundry** (Solidity development framework):
  ```sh
  curl -L https://foundry.paradigm.xyz | bash
  foundryup
  ```
- Install **Node.js** and **npm** (optional, if using Hardhat for deployment)

### Clone Repository

```sh
git clone <repo-url>
cd Task-Manager
```

### Install Dependencies

```sh
forge install
```

---

## Smart Contract

### `TaskManager.sol`

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";

contract TaskManager is Ownable {
    uint128 public totalTaskCount;

    event TaskCreated(uint256 indexed taskId, string Title, string Description);
    event TaskUpdated(uint256 indexed taskId, string Title, string Description, bool Status);
    event TaskDeleted(uint256 indexed taskId);

    struct Task {
        string Title;
        string Description;
        bool Status;
    }

    mapping(uint256 => Task) public tasks;
    mapping(uint256 => bool) private taskExists;

    constructor(address _initialOwner) Ownable(_initialOwner) {}

    function createTask(string calldata _title, string calldata _description) external onlyOwner {
        unchecked { totalTaskCount++; }
        tasks[totalTaskCount] = Task(_title, _description, false);
        taskExists[totalTaskCount] = true;
        emit TaskCreated(totalTaskCount, _title, _description);
    }

    function updateTask(uint256 _taskId, string calldata _title, string calldata _description, bool _status) external onlyOwner {
        require(taskExists[_taskId], "Task does not exist");
        Task storage task = tasks[_taskId];
        task.Title = _title;
        task.Description = _description;
        task.Status = _status;
        emit TaskUpdated(_taskId, _title, _description, _status);
    }

    function deleteTask(uint256 _taskId) external onlyOwner {
        require(taskExists[_taskId], "Task does not exist");
        delete tasks[_taskId];
        delete taskExists[_taskId];
        emit TaskDeleted(_taskId);
    }

    function getTask(uint256 _taskId) external view returns (Task memory) {
        require(taskExists[_taskId], "Task does not exist");
        return tasks[_taskId];
    }

    function getAllTasks() external view returns (Task[] memory) {
        Task[] memory allTasks = new Task[](totalTaskCount);
        uint256 index;

        for (uint256 i = 1; i <= totalTaskCount;) {
            if (taskExists[i]) {
                allTasks[index] = tasks[i];
                unchecked { index++; }
            }
            unchecked { i++; }
        }

        assembly { mstore(allTasks, index) }
        return allTasks;
    }
}
```

---

## Testing with Foundry

Run tests to ensure the contract functions as expected.

```sh
forge test
```

To check gas usage per function:

```sh
forge snapshot
```

---

## Deployment

### Using Foundry

1. Build the contract:
   ```sh
   forge build
   ```
2. Deploy using a private key (Replace `<PRIVATE_KEY>` with your actual key):
   ```sh
   forge create --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> src/TaskManager.sol:TaskManager --constructor-args <OWNER_ADDRESS>
   ```

### Using Hardhat (Optional)

1. Compile:
   ```sh
   npx hardhat compile
   ```
2. Deploy script (Example):

   ```javascript
   const { ethers } = require("hardhat");

   async function main() {
       const TaskManager = await ethers.getContractFactory("TaskManager");
       const taskManager = await TaskManager.deploy(<OWNER_ADDRESS>);
       await taskManager.deployed();
       console.log("Contract deployed at:", taskManager.address);
   }

   main().catch(error => {
       console.error(error);
       process.exitCode = 1;
   });
   ```

3. Run the script:
   ```sh
   npx hardhat run scripts/deploy.js --network <NETWORK>
   ```

---

## Contract Verification

Verify the contract on Etherscan:

```sh
forge verify-contract --chain-id <CHAIN_ID> --etherscan-api-key <API_KEY> --contract-address <DEPLOYED_ADDRESS> src/TaskManager.sol:TaskManager
```

---

## License

This project is licensed under the **MIT License**.

## Author

**Kachapuram Nagateja**

---

## Notes

- Make sure to replace placeholders (`<PRIVATE_KEY>`, `<RPC_URL>`, `<NETWORK>`, `<CHAIN_ID>`, `<DEPLOYED_ADDRESS>`, `<API_KEY>`) with actual values.
- Gas optimizations have been applied to improve efficiency.
- The contract uses `Ownable` from OpenZeppelin to restrict task management to the owner.

---
