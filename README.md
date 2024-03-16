### Petrol Station Simulator

Each car, station with dispenser, and queue consumer work in their own threads.
There is a timer that syncs them.

The purpose of simulation is to find an optimal station/dispenser/queueing setup.
The metric is an avarage waiting time of a car.

Future ideas: more stations, more dispensers, transactions, visualising, online game etc.

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
Fueling speed: 0.5 litre/second
Fuel reserve: 1000
Cars to arrive: 5
Closing tick: 200

00000: Station opens. Awaiting cars.
00039: Car#8747 has arrived and is 1 in queue
00040: Car#8747 waited 1 seconds to fuel
00040: Car#8747 starts fueling 36 litres
00059: Car#8685 has arrived and is 1 in queue
00087: Car#1039 has arrived and is 2 in queue
00094: Car#6444 has arrived and is 3 in queue
00096: Car#3415 has arrived and is 4 in queue
00112: Tanked 36 liters of Car#8747 in 72.0 seconds
00113: Car#8685 waited 54 seconds to fuel
00113: Car#8685 starts fueling 22 litres
00157: Tanked 22 liters of Car#8685 in 44.0 seconds
00157: Car#1039 waited 70 seconds to fuel
00157: Car#1039 starts fueling 62 litres
00200: Station closes. Finishing last client! Goodbye!
00281: Tanked 62 liters of Car#1039 in 124.0 seconds

Results:
Cars served: 3
Cars left: 2
Avg car wait: 121.667 seconds
Litres left in station: 880 litres

Petrolex Station Simulator has ended.
```

All clients fueled:
```
Petrolex Station Simulator has started.

Simulation speed: x100
Fueling speed: 0.5 litre/second
Fuel reserve: 1000
Cars to arrive: 5
Closing tick: 500

00000: Station opens. Awaiting cars.
00011: Car#6106 has arrived and is 1 in queue
00011: Car#6106 waited 0 seconds to fuel
00011: Car#6106 starts fueling 46 litres
00034: Car#5917 has arrived and is 1 in queue
00042: Car#9467 has arrived and is 2 in queue
00074: Car#5667 has arrived and is 3 in queue
00084: Car#7345 has arrived and is 4 in queue
00103: Tanked 46 liters of Car#6106 in 92.0 seconds
00104: Car#5917 waited 70 seconds to fuel
00104: Car#5917 starts fueling 34 litres
00172: Tanked 34 liters of Car#5917 in 68.0 seconds
00173: Car#9467 waited 131 seconds to fuel
00173: Car#9467 starts fueling 64 litres
00301: Tanked 64 liters of Car#9467 in 128.0 seconds
00302: Car#5667 waited 228 seconds to fuel
00302: Car#5667 starts fueling 46 litres
00394: Tanked 46 liters of Car#5667 in 92.0 seconds
00394: Car#7345 waited 310 seconds to fuel
00395: Car#7345 starts fueling 21 litres
00437: Tanked 21 liters of Car#7345 in 42.0 seconds
00500: Station closes. Goodbye!

Results:
Cars served: 5
Cars left: 0
Avg car wait: 232.4 seconds
Litres left in station: 789 litres

Petrolex Station Simulator has ended.
```