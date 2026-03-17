# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
bundle install               # Install dependencies
bundle exec ruby tasks/runner.rb                        # Run default simulation
bundle exec ruby tasks/runner.rb --scenario alpha       # Run named scenario
bundle exec ruby tasks/runner.rb --aa                   # Run with ASCII art visualization
bundle exec ruby tasks/runner.rb --silent               # Suppress log output
bundle exec m test           # Run all tests
bundle exec m test/path/to/test_file.rb                 # Run a single test file
rubocop                      # Lint
```

## Architecture

Petrolex is a petrol station simulator built on cooperative concurrency (`async` gem). Its goal is to find optimal gas station configurations by minimizing average customer wait time across different pump/queue setups.

### Simulation Flow

**Entry point**: `tasks/runner.rb` — parses CLI options, delegates to `ScenarioLoader` to build simulations from `config/simulations.yml`, then runs them via `Petrolex::Runner`.

Each simulation (`app/simulation.rb`) spawns concurrent async tasks synchronized by a global timer (`app/timer.rb`):
1. **Station task** — opens/closes the station at configured ticks
2. **Queue consumer task** — spawns a sub-task per pump via an inner `Async::Barrier`; pulls cars from queue and fuels them
3. **Car spawner task** — generates cars at random intervals matching scenario config
4. **Road task** (optional, `--aa`) — drives ASCII animation
5. **Report saver task** — periodically serializes metrics to JSON for the frontend

### Key Modules

| File | Role |
|------|------|
| `app/station.rb` | Fuel reserve, pump management, cost tracking |
| `app/pump.rb` | Per-pump fueling logic |
| `app/queue.rb` | Car queue using `Async::Condition` for producer-consumer signaling |
| `app/car.rb` | Car entity (plate, fuel level, desired volume) |
| `app/report.rb` | Report container; `.for(station_name:)` returns a `StationSheet` |
| `app/station_sheet.rb` | Per-station metrics: counts, averages, financials |
| `app/scenario_loader.rb` | Loads `config/simulations.yml` and builds `Simulation` objects |
| `app/report_saver.rb` | Serializes stats to `frontend/*.json` |
| `app/ascii_art.rb` | Renders up to 2 simulations side-by-side in the terminal |
| `app/ascii_board.rb` | `BOARD` template constant used by `AsciiArt` |
| `app/logger.rb` | Colored logging; respects `--silent` |

### Configuration

Scenarios are defined in `config/simulations.yml` using YAML anchors. Each simulation entry specifies car arrival patterns, pump count/speed, fuel reserve, and closing tick. Predefined scenarios: `alpha`, `beta`, `gamma`, `demo-two`, `demo-nine`, `manager`.

### Frontend

`frontend/` contains a static dashboard (`index.html`) that reads JSON files written by `ReportSaver` during simulation:
- `charts.json` — time-series data for line/bar charts
- `bubbles.json` — bubble chart data (via `app/graph.rb`)

The `.json` files are gitignored and regenerated each run.

### Concurrency Model

All async tasks share a global `Timer` instance that controls tick progression. The `async` gem's cooperative fiber scheduler is used throughout — no OS threads or mutexes. Key primitives:

- **`Async::Barrier`** — in `Simulation#run` to wait for all tasks; in `Queue#consume` to wait for all pump sub-tasks
- **`Async::Condition`** — in `Queue` for producer-consumer signaling between the car spawner and pump tasks
- **`Async::Task.current.async`** — in `Timer#start` to spawn the tick loop as a child task

Multiple simulations run concurrently via the outer `Async` block in `Runner`.
