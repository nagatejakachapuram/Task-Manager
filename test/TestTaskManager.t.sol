// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {TaskManager} from "../src/TaskManager.sol";
import {Ownable} from "@openzeppelin-contracts/contracts/access/Ownable.sol";

contract TestTaskManager is Test {
    TaskManager taskManager;
    address deployer;

    function setUp() external {
        deployer = address(this); // Set deployer to the test contract's address
        taskManager = new TaskManager(deployer); // Pass the correct deployer
        assertEq(taskManager.owner(), deployer, "Owner should be the deployer");
    }

    function testOnlyOwnerCanCreateTask() external {
        vm.prank(address(0x1234)); // Simulate a non-owner caller
        vm.expectRevert(); // This will catch any revert without needing exact error
        taskManager.createTask("Task1", "Task1 Description");
    }

    function testTaskCreated() external {
        taskManager.createTask("Task1", "Task1 Description");
        assertEq(taskManager.totalTaskCount(), 1, "Total task count should be 1");
    }

    function testTaskUpdated() external {
        taskManager.createTask("Task1", "Task1 Description");
        taskManager.updateTask(1, "Task1 Updated", "Task1 Description Updated", true);

        TaskManager.Task memory task = taskManager.getTask(1);
        assertEq(task.Title, "Task1 Updated", "Title should be updated");
        assertEq(task.Description, "Task1 Description Updated", "Description should be updated");
        assertTrue(task.Status, "Status should be updated");
    }

    function testDeleteTask() public {
    taskManager.createTask("Task 1", "Description 1");
  
    assertEq(taskManager.totalTaskCount(), 1, "Total task count should be 1");
    taskManager.deleteTask(1);

    vm.expectRevert("Task does not exist");
    taskManager.getTask(1); // Should fail

}


    function testGetAllTasks() external {
        taskManager.createTask("Task1", "Task1 Description");
        taskManager.createTask("Task2", "Task2 Description");
        taskManager.createTask("Task3", "Task3 Description");

        TaskManager.Task[] memory allTasks = taskManager.getAllTasks();
        assertEq(allTasks.length, 3, "Task count should be 3");
        assertEq(allTasks[0].Title, "Task1", "First task title should be Task1");
        assertEq(allTasks[1].Title, "Task2", "Second task title should be Task2");
        assertEq(allTasks[2].Title, "Task3", "Third task title should be Task3");
    }

    // Testing Revert cases

    function testCreateTask_NotOwner() public {
        vm.prank(address(0x123)); // Impersonate a non-owner account
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(0x123)));
        taskManager.createTask("Unauthorized", "Should fail");
    }

    function testUpdateTask_TaskDoesNotExist() public {
        vm.expectRevert("Task does not exist");
        taskManager.updateTask(499, "Non-existent", "Fails", false);
    }

    function testMarkTaskAsCompleted_TaskDoesNotExist() public {
        vm.expectRevert("Task does not exist");
        taskManager.markTaskAsCompleted(9999);
    }

    function testMarkTaskAsCompleted_AlreadyCompleted() public {
        taskManager.createTask("Task", "Test");
        taskManager.markTaskAsCompleted(1);

        vm.expectRevert("Task is already completed");
        taskManager.markTaskAsCompleted(1);
    }

    function testDeleteTask_TaskDoesNotExist() public {
        vm.expectRevert("Task does not exist");
        taskManager.deleteTask(9999);
    }
}
