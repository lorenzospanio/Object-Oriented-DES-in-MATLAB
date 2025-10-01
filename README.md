

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
- **`EventManager.m` / `discrete_event.m`**: Defines the logic for handling different types of events ( arrival, completion, supply delivery).
- **`StatisticsManager.m`**: Responsible for collecting, processing, and reporting all statistical data.
- **`queue.m`**: A generic class defining a queue in the system.
- **`Customer.m` / `clients.m`**: Define the entities that move through the system, including their types, preferences, and arrival processes.
- **`supplyManager.m` / `policyOrder.m`**: Manage the inventory of resources (fuel) and the logic for re-ordering supplies.
- **`connector.m` / `direction_connector.m`**: Defines the routing logic for customers moving between queues.
- **`test2.m`**: The main script to configure the simulation parameters and start the `SimulationManager`.


To run the simulation, follow these steps:

1.  Clone the repository or download all the `.m` files into a single folder.
2.  In the MATLAB command window, navigate to the folder containing the project files.
3.  Open the `test2.m` script.
4.  Modify the simulation parameters within this file as needed (arrival rates, service times, number of simulations).
5.  Run the `test2.m` script 



