This project is a basis for an online video course on TDD.

It simulates a petrol station.

In its current stage it has two main classes: Station and Car.

It works on threads.

Car in threads share access to the Station.

Future:
- Add classes: FuelDispenser, Counter, Client
- Add queueing systems

The purpose of simulation is to find an optimal station setup.

The measurement is an avarage waiting time of a car.

Have fun!

```
bundle install
bundle exec m test/
bundle exec ruby tasks/runner.rb
```
