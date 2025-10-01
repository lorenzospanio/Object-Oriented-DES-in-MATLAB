# Object-Oriented-DES-in-MATLAB
An object-oriented discrete-event simulation framework in MATLAB, demonstrated with complex queues.

# MATLAB Gas Station Simulation Framework

![Language](https://img.shields.io/badge/Language-MATLAB-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

An object-oriented discrete-event simulation (DES) framework built in MATLAB. The framework's capabilities are demonstrated through a detailed model of a multi-pump gas station with complex customer behavior, inventory management, and resource contention.

## About The Project

This project was developed to model and analyze complex queueing systems using a robust, object-oriented architecture in MATLAB. The core of the project is a flexible DES engine capable of handling various event types, statistical distributions, and system states.

The example simulation models a gas station with the following characteristics:
*   An entrance queue where cars arrive.
*   Multiple parallel pumps, creating choices for arriving customers.
*   Customer preferences for certain pumps.
*   Blocking, where a car cannot proceed if the next station is full.
*   A centralized payment queue.
*   Complex customer routing: cars go to a pump, then the driver walks to pay, and then returns to the pump area before exiting the system.
*   Inventory management for three different types of fuel, using an (s, S) ordering policy.

The goal is to provide a clear and extensible example of how to apply OOP principles to build sophisticated simulation models.

## Key Features

- **Object-Oriented Design:** Clear separation of concerns with classes for State, Events, Statistics, Queues, Customers, etc.
- **Event-Driven Engine:** The simulation progresses based on a future event list, managed by the `Future_event_Manager`.
- **Flexible Event Generation:** Supports various random distributions (Exponential, Normal, etc.) and deterministic schedules for arrivals and service times.
- **Advanced Queueing Logic:** Implements finite-capacity queues, blocking, and complex routing managed by a `connector` class.
- **Statistical Analysis:** The `StatisticsManager` collects key performance metrics like customer flow time, queue lengths, server utilization, and clients lost. It also supports transient period removal and calculates confidence intervals over multiple simulations.
- **Inventory Management:** Includes a `policyOrder` class to implement an (s, S) inventory control policy for fuel replenishment.
- **Multi-Simulation Runner:** The `SimulationManager` can run multiple replications of the simulation and aggregate the final statistics.

## Project Structure

The project is organized into several key classes, each with a specific responsibility:

- **`SimulationManager.m`**: The main controller that initializes and runs multiple simulation replications.
- **`StateManager.m` / `Future_event_Manager.m`**: Manages the simulation's state (clock, queues, resources) and the list of future events.
- **`EventManager.m` / `discrete_event.m`**: Defines the logic for handling different types of events (e.g., arrival, completion, supply delivery).
- **`StatisticsManager.m`**: Responsible for collecting, processing, and reporting all statistical data.
- **`queue.m`**: A generic class defining a queue in the system.
- **`Customer.m` / `clients.m`**: Define the entities that move through the system, including their types, preferences, and arrival processes.
- **`supplyManager.m` / `policyOrder.m`**: Manage the inventory of resources (fuel) and the logic for re-ordering supplies.
- **`connector.m` / `direction_connector.m`**: Defines the routing logic for customers moving between queues.
- **`test2.m`**: The main script to configure the simulation parameters and start the `SimulationManager`.

## Getting Started

To run the simulation, follow these steps:

1.  Clone the repository or download all the `.m` files into a single folder.
2.  Open MATLAB.
3.  In the MATLAB command window, navigate to the folder containing the project files.
4.  Open the `test2.m` script.
5.  Modify the simulation parameters within this file as needed (e.g., arrival rates, service times, number of simulations).
6.  Run the `test2.m` script by pressing F5 or typing `test2` in the command window.

```matlab
% --- In test2.m ---

% Adjust number of simulations
number_of_simulations = 10;

% Adjust simulation end conditions
max_serverd = 150;
max_clock = 5000;

% Adjust client arrival rates in 'parameters_arrivals'
parameters_arrivals = { {'mu', 5}, {'mu', 4, 'sigma', 0.5}, {'mu', 3}}; 

% ... other parameters ...

% Run the script
```
The final aggregated statistics will be displayed in the command window upon completion.

## Contributing

Contributions are welcome! If you have ideas for improvements, please feel free to fork the repository and submit a pull request. Some potential areas for improvement include:

- **Visualization:** Add plotting functions to visualize results, such as queue length over time or histograms of customer waiting times.
- **Code Documentation:** Add standard MATLAB help comments (H1 lines and `help` blocks) to all class methods.
- **Unit Testing:** Implement a testing suite to verify the logic of individual components.
- **GUI:** Develop a simple Graphical User Interface to change parameters and run the simulation.

## License

This project is licensed under the MIT License - see the `LICENSE` file for details.

## Author

[Your Name] - [Your Email or Website]
