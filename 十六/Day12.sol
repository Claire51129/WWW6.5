// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProjectManager {
    struct Project {
        string name;
        uint256 targetAmount;
        uint256 currentAmount;
        address owner;
        bool active;
    }

    Project[] public projects;
    mapping(uint256 => mapping(address => uint256)) public contributions;

    event ProjectCreated(uint256 projectId, string name, uint256 targetAmount);
    event Donated(uint256 projectId, address donor, uint256 amount);

    function createProject(string memory _name, uint256 _targetAmount) public {
        Project memory newProject = Project({
            name: _name,
            targetAmount: _targetAmount,
            currentAmount: 0,
            owner: msg.sender,
            active: true
        });
        projects.push(newProject);
        emit ProjectCreated(projects.length - 1, _name, _targetAmount);
    }

    function donate(uint256 _projectId) public payable {
        require(_projectId < projects.length, "Project does not exist");
        Project storage project = projects[_projectId];
        require(project.active, "Project is not active");
        require(msg.value > 0, "Donation must be greater than 0");

        project.currentAmount += msg.value;
        contributions[_projectId][msg.sender] += msg.value;

        if (project.currentAmount >= project.targetAmount) {
            project.active = false;
        }

        emit Donated(_projectId, msg.sender, msg.value);
    }

    function getProjectCount() public view returns (uint256) {
        return projects.length;
    }

    function getProject(uint256 _projectId) public view returns (
        string memory name,
        uint256 targetAmount,
        uint256 currentAmount,
        address owner,
        bool active
    ) {
        Project storage project = projects[_projectId];
        return (
            project.name,
            project.targetAmount,
            project.currentAmount,
            project.owner,
            project.active
        );
    }
}
