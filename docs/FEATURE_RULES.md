# EDEN Feature Rules

This document defines the rules for proposing and adding features to The EDEN Project.

## Core Rule

A feature may only be added to the official project if it fits the current world state or includes the full chain of systems needed to make it possible.

The EDEN Project should not allow objects, tools, weapons, buildings, vehicles, or technologies to appear without the required supporting resources, knowledge, tools, and production processes.

## Technology Progression Rule

Advanced items are allowed only if the systems needed to create them also exist.

For example, a vehicle would require many supporting systems, such as:

* Material generation
* Resource gathering
* Mining
* Processing
* Toolmaking
* Blacksmithing
* Casting
* Machining
* Component manufacturing
* Assembly systems
* Fuel or power systems
* Maintenance systems

Because of this, highly advanced items are theoretically allowed but practically difficult to add.

## No Random Spawning

Features should not appear randomly just because a contributor wants them.

A contributor proposing an item or system must explain:

1. Why it belongs in the world.
2. What resources are required.
3. What knowledge or process is required.
4. How the player or world obtains it.
5. What gameplay purpose it serves.

## Weapons and Dangerous Technology

Weapons, explosives, and similar systems may exist as abstract in-game mechanics if they fit the project’s progression rules.

Contributions should not include real-world instructional details for creating weapons, explosives, or harmful devices.

## Feature Proposal Requirement

Large features should be proposed before being built.

A feature proposal should include:

* Feature name
* Purpose
* Gameplay impact
* Required assets
* Required systems
* Technical risks
* Canon explanation
* Testing plan

## Pull Request Requirement

A pull request should be small enough to review.

Large systems should be split into smaller pull requests when possible.

Good pull requests include:

* Clear description
* Working code
* Tested scenes
* No new debugger errors
* Proper collision where needed
* Asset license information
* Screenshots or video if visual changes were made

## Maintainer Review

Maintainers may reject a feature if it:

* Breaks the project direction
* Skips required progression systems
* Adds unsupported technology
* Adds unclear or unlicensed assets
* Causes technical instability
* Is too large to review safely
* Introduces unsafe real-world instructional content
