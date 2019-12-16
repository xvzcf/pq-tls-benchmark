Given below are the steps to run the experiments. They should work on sufficiently recent versions of Ubuntu (18.04+) with sufficiently recent versions of the Linux kernel (4.12+).

0) Run `./install-prereqs-ubuntu.sh`
1) To run the key-exchange experiments, navigate to `kex`, and run `./setup.sh` followed by `python3 experiment.py`. To cleanup, run `./teardown.sh`.
2) To run the signature experiments, navigate to `sig`, and run `./setup.sh` followed by `./run.sh`. To cleanup, run `./teardown.sh`.

Make sure to cleanup before switching from the key-exchange experiments to the signature ones and vice-versa.
