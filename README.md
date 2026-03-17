### Petrol Station Simulator

Each car, station with pumps, and queue consumer run as async tasks (via the `async` gem), synchronized by a shared timer. The goal is to find an optimal station/pump/queueing setup by minimizing average customer wait time across different configurations.

### Install & run

```bash
bundle install
bundle exec ruby tasks/runner.rb                   # default scenario (alpha)
bundle exec ruby tasks/runner.rb --scenario alpha  # named scenario
bundle exec ruby tasks/runner.rb --silent          # suppress log output
bundle exec ruby tasks/runner.rb --aa              # ASCII art visualisation (2 simulations)
```

Available scenarios: `alpha`, `beta`, `gamma`, `demo-two`, `demo-nine`, `manager`

### Tests

```bash
bundle exec m test                         # all tests
bundle exec m test/report_test.rb          # single file
```

### Sample output

```
Sim 0 has started.

Simulation speed: x20
Closing tick: 200
Cars to arrive: 5
Station fuel reserve: 200
Pumps fueling speeds: 1, 2, 3

Tick | Message
--------------

000000: Station opens
000003: PGN-1 is 1 in queue
000003: Pump1 pumping PGN-1
000006: WAW-2 is 1 in queue
000006: Pump2 pumping WAW-2
000006: Pump2 pumped 0 litres of fuel into WAW-2 in 0 seconds
000010: PGN-3 is 1 in queue
000010: Pump2 pumping PGN-3
000020: KRA-4 is 1 in queue
000020: Pump1 pumped 17 litres of fuel into PGN-1 in 17 seconds
000020: Pump1 pumping KRA-4
000023: KRA-5 is 1 in queue
000023: Pump3 pumping KRA-5
000040: Pump1 pumped 20 litres of fuel into KRA-4 in 20 seconds
000042: Pump2 pumped 16 litres of fuel into PGN-3 in 32 seconds
000140: Pump3 pumped 39 litres of fuel into KRA-5 in 117 seconds
000200: Station closes

Results:
Cars fully fueled: 4
Cars partialy fueled: 0
Cars not fueled due to lack of fuel: 1
Cars left in queue: 0

Fuel left in station: 108 litres
Fuel pumped in cars: 92 litres

Avg waiting time: 0.0 seconds
Avg fueling time: 46.5 seconds
Avg fueling speed: 2.02 litres per second

Sim 0 has ended.

Simulation took 11.026036 seconds
```