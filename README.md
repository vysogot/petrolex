### Petrol Station Simulator

Each car, station with pump, and queue consumer work in their own threads.
There is a timer that syncs them.

The purpose of simulation is to find an optimal station/pump/queueing setup.
The metric is an avarage waiting time of a car.

Future ideas: more stations, more pumps, transactions, visualising, online game etc.

Have fun!

### Install

```
bundle install
bundle exec m test # in progress
bundle exec ruby tasks/runner.rb
```

### Sample outputs

Some clients left unfueled:
```
Petrolex Station Simulator has started.

Simulation speed: x100
Closing tick: 1000

Cars to arrive: 5
Station fuel reserve: 100
Pump fueling speed: 0.5 litre/second

Tick | Message
--------------
00000: Station opens. Awaiting cars.
00022: Car#6420 has arrived and is 1 in queue
00023: Car#6420 waited 1 seconds to fuel
00023: Car#6420 starts fueling 30 litres
00033: Car#2662 has arrived and is 1 in queue
00048: Car#4168 has arrived and is 2 in queue
00066: Car#3882 has arrived and is 3 in queue
00078: Car#6791 has arrived and is 4 in queue
00083: Car#6420 got 30 liters in 60.0 seconds
00084: Car#2662 waited 51 seconds to fuel
00084: Car#2662 starts fueling 39 litres
00162: Car#2662 got 39 liters in 78.0 seconds
00163: Car#4168 needed 38 litres and has left due to lack of fuel
00164: Car#3882 waited 98 seconds to fuel
00164: Car#3882 starts fueling 30 litres
00224: Car#3882 got 30 liters in 60.0 seconds
00225: Car#6791 needed 17 litres and has left due to lack of fuel
01000: Station closes. Goodbye!

Results:
Cars served: 3
Cars left in line: 0
Cars left the station unserved: 2

Avg wait time: 50.0 seconds
Avg fueling time: 66.0 seconds
Fuel left in station: 1 litres

Petrolex Station Simulator has ended.
```

All clients fueled:
```
Petrolex Station Simulator has started.

Simulation speed: x1000
Closing tick: 1000

Cars to arrive: 5
Station fuel reserve: 1000
Pump fueling speed: 0.5 litre/second

Tick | Message
--------------
00000: Station opens. Awaiting cars.
00015: Car#6045 has arrived and is 1 in queue
00015: Car#6045 waited 0 seconds to fuel
00015: Car#6045 starts fueling 42 litres
00062: Car#5663 has arrived and is 1 in queue
00073: Car#9201 has arrived and is 2 in queue
00092: Car#4503 has arrived and is 3 in queue
00099: Car#6045 got 42 liters in 84.0 seconds
00100: Car#5663 waited 38 seconds to fuel
00100: Car#5663 starts fueling 29 litres
00100: Car#789 has arrived and is 3 in queue
00158: Car#5663 got 29 liters in 58.0 seconds
00159: Car#9201 waited 86 seconds to fuel
00159: Car#9201 starts fueling 3 litres
00165: Car#9201 got 3 liters in 6.0 seconds
00166: Car#4503 waited 74 seconds to fuel
00166: Car#4503 starts fueling 46 litres
00258: Car#4503 got 46 liters in 92.0 seconds
00259: Car#789 waited 159 seconds to fuel
00259: Car#789 starts fueling 49 litres
00357: Car#789 got 49 liters in 98.0 seconds
01000: Station closes. Goodbye!

Results:
Cars served: 5
Cars left in line: 0
Cars left the station unserved: 0

Avg wait time: 71.4 seconds
Avg fueling time: 67.6 seconds
Fuel left in station: 831 litres

Petrolex Station Simulator has ended.
```

### TODO

#### Runner

* Is getting hard to read

#### Tests

* Out of date

#### Queue, station, pump

* All need refactoring but now work on a right basis
* The code is completely WIP

#### Issues

* Report in unstructured and needs its own object, same with single records
* Report needs aggregations
* Report needs access to how many cars didn't reach
* Report may have inaccurate data
