# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
bundle install               # Install dependencies
bundle exec ruby tasks/runner.rb                        # Run default simulation
bundle exec ruby tasks/runner.rb --scenario alpha       # Run named scenario
bundle exec ruby tasks/runner.rb --aa                   # Run with ASCII art visualization
bundle exec ruby tasks/runner.rb --silent               # Suppress log output
bundle exec m test           # Run tests
rubocop                      # Lint
```

Run a single test file:
```bash
bundle exec m test/path/to/test_file.rb
```

## Architecture

Petrolex is a multi-threaded petrol station simulator. Its goal is to find optimal gas station configurations by minimizing average customer wait time across different pump/queue setups.

### Simulation Flow

**Entry point**: `tasks/runner.rb` — parses CLI options, loads scenario config from `config/simulations.yml`, and runs simulations via `Petrolex::Runner`.

Each simulation (`app/simulation.rb`) spawns concurrent threads synchronized by a global timer (`app/timer.rb`):
1. **Station thread** — opens/closes the station at configured ticks
2. **Queue consumer thread** — spawns a sub-thread per pump; pulls cars from queue and fuels them
3. **Car spawner thread** — generates cars at random intervals matching scenario config
4. **Road thread** (optional, `--aa`) — drives ASCII animation
5. **Report saver thread** — periodically serializes metrics to JSON for the frontend

### Key Modules

| File | Role |
|------|------|
| `app/station.rb` | Fuel reserve, pump management, cost tracking |
| `app/pump.rb` | Per-pump fueling logic |
| `app/queue.rb` | Thread-safe car queue using mutex + condition variables |
| `app/car.rb` | Car entity (plate, fuel level, desired volume) |
| `app/report.rb` | Tracks car outcomes (waiting, served, full, partial, none); computes metrics |
| `app/report_saver.rb` | Serializes stats to `frontend/*.json` |
| `app/ascii_art.rb` | Renders up to 2 simulations side-by-side in the terminal |
| `app/logger.rb` | Thread-safe colored logging; respects `--silent` |

### Configuration

Scenarios are defined in `config/simulations.yml` using YAML anchors. Each simulation entry specifies car arrival patterns, pump count/speed, fuel reserve, and closing tick. Predefined scenarios: `alpha`, `beta`, `gamma`, `demo-two`, `demo-nine`, `manager`.

### Frontend

`frontend/` contains a static dashboard (`index.html`) that reads JSON files written by `ReportSaver` during simulation:
- `charts.json` — time-series data for line/bar charts
- `bubbles.json` — bubble chart data (via `app/graph.rb`)

The `.json` files are gitignored and regenerated each run.

### Thread Synchronization

All threads share a global `Timer` instance that controls tick progression. The queue uses a `Mutex` + `ConditionVariable` pair. Multiple simulations can run concurrently via the `async` gem.

## Known Issues (from README)

- Tests are out of date
- Report data may have inaccuracies and is unstructured
- Runner code needs refactoring (acknowledged as hard to read)
