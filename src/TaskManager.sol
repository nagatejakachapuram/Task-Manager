// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title TaskManager
 * @author Kachapuram Nagateja
 * @notice A contract for managing tasks, allowing the owner to create, update, mark as completed, and delete tasks.
 * @dev Optimized for gas efficiency, utilizing `calldata`, `unchecked` arithmetic, and storage access optimizations.
 */
contract TaskManager is Ownable {
    /// @notice Total number of tasks created
    uint128 public totalTaskCount;

    /// @notice Event emitted when a new task is created
    event TaskCreated(uint256 indexed taskId, string Title, string Description);

    /// @notice Event emitted when a task is updated
    event TaskUpdated(uint256 indexed taskId, string Title, string Description, bool Status);

    /// @notice Event emitted when a task is deleted
    event TaskDeleted(uint256 indexed taskId);

    /// @notice Structure representing a task
    struct Task {
        string Title;
        string Description;
        bool Status;
    }

    /// @notice Mapping of task ID to Task structure
    mapping(uint256 taskId => Task) public tasks;

    /// @notice Mapping to track if a task exists
    mapping(uint256 => bool) private taskExists;

    /**
     * @dev Initializes the contract with an initial owner.
     * @param _initialOwner The address of the contract owner.
     */
    constructor(address _initialOwner) Ownable(_initialOwner) {}

    /**
     * @notice Creates a new task.
     * @dev Only the contract owner can create tasks.
     * @param _title The title of the task.
     * @param _description The description of the task.
     */
    function createTask(string calldata _title, string calldata _description) external onlyOwner {
        unchecked {
            totalTaskCount++;
        }
        tasks[totalTaskCount] = Task(_title, _description, false);
        taskExists[totalTaskCount] = true;

        emit TaskCreated(totalTaskCount, _title, _description);
    }

    /**
     * @notice Updates an existing task with new details.
     * @dev Only the contract owner can update tasks. Uses storage optimization.
     * @param _taskId The ID of the task to update.
     * @param _title The new title of the task.
     * @param _description The new description of the task.
     * @param _status The updated status of the task (true = completed, false = not completed).
     */
    function updateTask(uint256 _taskId, string calldata _title, string calldata _description, bool _status)
        external
        onlyOwner
    {
        require(taskExists[_taskId], "Task does not exist");

        Task storage task = tasks[_taskId];
        task.Title = _title;
        task.Description = _description;
        task.Status = _status;

        emit TaskUpdated(_taskId, _title, _description, _status);
    }

    /**
     * @notice Marks a task as completed.
     * @dev Only the contract owner can mark tasks as completed.
     * @param _taskId The ID of the task to mark as completed.
     */
    function markTaskAsCompleted(uint256 _taskId) external onlyOwner {
        require(taskExists[_taskId], "Task does not exist");

        Task storage task = tasks[_taskId];
        require(!task.Status, "Task is already completed");

        task.Status = true;
        emit TaskUpdated(_taskId, task.Title, task.Description, true);
    }

    /**
     * @notice Deletes a task.
     * @dev Only the contract owner can delete tasks. Marks them as non-existent.
     * @param _taskId The ID of the task to delete.
     */
    function deleteTask(uint256 _taskId) external onlyOwner {
        require(taskExists[_taskId], "Task does not exist");

        delete tasks[_taskId];
        delete taskExists[_taskId];

        emit TaskDeleted(_taskId);
    }

    /**
     * @notice Retrieves a specific task by ID.
     * @dev Returns the task details if it exists.
     * @param _taskId The ID of the task to retrieve.
     * @return The Task struct containing the task details.
     */
    function getTask(uint256 _taskId) external view returns (Task memory) {
        require(taskExists[_taskId], "Task does not exist");
        return tasks[_taskId];
    }

    /**
     * @notice Retrieves all active tasks.
     * @dev Uses optimized storage iteration and dynamic array resizing.
     * @return An array of all existing tasks.
     */
    function getAllTasks() external view returns (Task[] memory) {
        Task[] memory allTasks = new Task[](totalTaskCount);
        uint256 index;

        for (uint256 i = 1; i <= totalTaskCount;) {
            if (taskExists[i]) {
                allTasks[index] = tasks[i];
                unchecked {
                    index++;
                }
            }
            unchecked {
                i++;
            }
        }

        // Reduce array size dynamically
        assembly {
            mstore(allTasks, index)
        }

        return allTasks;
    }
}
