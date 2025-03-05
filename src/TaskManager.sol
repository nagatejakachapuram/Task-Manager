// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title TaskManager
 * @author Kachapuram Nagateja.
 * @dev A contract to manage tasks, allowing the owner to create, update, mark as completed, and delete tasks.
 */
contract TaskManager is Ownable {
    /// @notice Total number of tasks created
    uint256 public totalTaskCount;

    /// @notice Emitted when a new task is created
    /// @param taskId The ID of the newly created task
    /// @param title The title of the task
    /// @param description The description of the task
    event TaskCreated(uint256 indexed taskId, string indexed title, string indexed description);

    /// @notice Emitted when a task is updated
    /// @param taskId The ID of the task being updated
    /// @param title The updated title of the task
    /// @param description The updated description of the task
    /// @param status The updated status of the task (true = completed, false = not completed)
    event TaskUpdated(uint256 indexed taskId, string indexed title, string indexed description, bool status);

    /// @notice Emitted when a task is deleted
    /// @param taskId The ID of the deleted task
    event TaskDeleted(uint256 indexed taskId);

    /// @notice Structure representing a task
    struct Task {
        string Title; // Task title
        string Description; // Task description
        bool Status; // Task status (true = completed, false = not completed)
    }

    /// @notice Mapping to store tasks by their ID
    mapping(uint256 taskId => Task) public Tasks;

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
    function createTask(string memory _title, string memory _description) external onlyOwner {
        totalTaskCount++;
        Tasks[totalTaskCount] = Task(_title, _description, false);
        emit TaskCreated(totalTaskCount, _title, _description);
    }

    /**
     * @notice Updates an existing task with new details.
     * @dev Only the contract owner can update tasks.
     * @param _taskId The ID of the task to update.
     * @param _title The new title of the task.
     * @param _description The new description of the task.
     * @param _status The updated status of the task (true = completed, false = not completed).
     */
    function markTask(uint256 _taskId, string memory _title, string memory _description, bool _status)
        external
        onlyOwner
    {
        require(_taskId > 0 && _taskId <= totalTaskCount, "Invalid task ID");
        Tasks[_taskId] = Task(_title, _description, _status);
        emit TaskUpdated(_taskId, _title, _description, _status);
    }

    /**
     * @notice Marks a task as completed.
     * @dev Only the contract owner can mark tasks as completed.
     * @param _taskId The ID of the task to mark as completed.
     */
    function markTaskAsCompleted(uint256 _taskId) external onlyOwner {
        require(_taskId > 0 && _taskId <= totalTaskCount, "Invalid task ID");
        require(!Tasks[_taskId].Status, "Task is already completed");

        Tasks[_taskId].Status = true;
        emit TaskUpdated(_taskId, Tasks[_taskId].Title, Tasks[_taskId].Description, true);
    }

    /**
     * @notice Deletes a task.
     * @dev Only the contract owner can delete tasks.
     * @param _taskId The ID of the task to delete.
     */
    function deleteTask(uint256 _taskId) external onlyOwner {
        require(_taskId > 0 && _taskId <= totalTaskCount, "Invalid task ID");
        totalTaskCount--;
        delete Tasks[_taskId];
        emit TaskDeleted(_taskId);
    }

    /**
     * @notice Retrieves all tasks.
     * @dev Returns an array of all tasks stored in the contract.
     * @return An array of Task structures.
     */
    function getAllTasks() external view returns (Task[] memory) {
        Task[] memory allTasks = new Task[](totalTaskCount);

        for (uint256 i = 1; i <= totalTaskCount; i++) {
            allTasks[i - 1] = Tasks[i];
        }
        return allTasks;
    }
}
