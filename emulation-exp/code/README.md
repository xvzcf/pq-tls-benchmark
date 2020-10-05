## Requirements

1. A sufficiently recent version of Ubuntu (18.04+)
2. A sufficiently recent version of the Linux kernel (4.12+)
3. If you want to use the liboqs version used by the most recent version of the paper, a CPU that supports the following extensions:
	- avx2
	- bmi1
	- bmi2
	- popcnt
	- sse2

## Steps

1. Run `./install-prereqs-ubuntu.sh`.

	- If your CPU does not satisfy requirement 3 above, you might have to either modify the build files in the [xvzcf/pq-tls-experiment branch](https://github.com/xvzcf/liboqs) yourself or change [this line](https://github.com/xvzcf/liboqs/blob/pq-tls-experiment/config/detect-cpu-extensions.c) to pull the most current liboqs from `https://github.com/open-quantum-safe/liboqs`


2. To run the key-exchange experiments, navigate to `kex`, and run `./setup.sh` followed by `python3 experiment.py`. To cleanup, run `./teardown.sh`.

3. To run the signature experiments, navigate to `sig`, and run `./setup.sh` followed by `./run.sh`. To cleanup, run `./teardown.sh`.

Make sure to cleanup before switching from the key-exchange experiments to the signature ones and vice-versa.
