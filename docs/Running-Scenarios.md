# Running Scenarios

## Set up Node Count and Network Settings

Edit the run-scenario*.sh file and adjust the expected node count to the intended number.

Edit core-image-launcher.py and edit the expected node count and network settings

Edit orchestrator.sh to set the desired number of cycles before a given scenario run is considered completed.


## Run Scenarios

Call "orchestrator.sh" with the desired scenario (1 or 2) to run.

```
./orchestrator.sh 1
```

The orchestrator will drive the builder and runners to set up the scenario, run it and then collect the results.


## Observing and Interacting with active Scenarios 

The Orchestrator will output messages directly on the stdout.

The Builder can be oserved via ./build_scenario.log
```
tail -F ./build_scenario.log
```

The Runner can be observed via ./scenario.log
```
tail -F ./scenario.log
```


To stop the run pematurely, create an empty file called "runner.conclude".
```
touch ./runner.conclude
```

To stop the orchestration prematurely, create an empty file called "orchestrator.conclude".
```
touch ./orchestrator.conclude
```


## Gathering Results

If a given run is completed (even if stopped prematurely), the Runner will collect three runtime files.

- XXXXXX_walltime.txt (Operator-specific timing)
- XXXXXX_scenario.csv (Detailed on-Node timing)
- XXXXXX_watcher.log (Resource monitoring)

XXXXX = YYYYMMHH at the time the run concluded.


## Recovering from failed runs

If a run fails, crashes or otherwise ends unexpectedly, remnant Containers & CORE network components can remain on the system.

The Runner and Orchestrators will automatically clean up the environment when launched.

If a cleanup is necessary without starting a new cycle, the environment can be reset with:

1. sudo podman stop -a -t 0
2. sudo podman container rm -a -f
3. sudo core-cleanup

Depending on the amount of nodes used, this can take a while to complete.

