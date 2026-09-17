# Reproducible revision package

This folder is a complete revision of the released MATLAB implementation. The
original folder is retained unchanged as `源代码`; the modified implementation
is in `source-code-revised`.

## Requirements

- MATLAB R2020b or later
- Statistics and Machine Learning Toolbox (`pdist`)
- Parallel Computing Toolbox is optional; use `parfor` only after a serial
  pilot run validates all functions.

## Main entry points

- `setup_environment.m`: adds the required folders to the MATLAB path and
  checks the required instance and `pdist` function.
- `experiments/run_smoke_test.m`: one small diagnostic run; execute this
  before `run_validation.m`.
- `experiments/run_mutation_sensitivity.m`: 600 runs for the Reviewer-1
  mutation-probability robustness experiment.
- `experiments/run_mutation_pilot.m`: measures formal-budget runtime on the
  four sensitivity-test scales before the 600-run experiment is started.
- `experiments/run_mutation_sensitivity_parallel.m`: parallel implementation
  of the 600-run sensitivity experiment; requires Parallel Computing Toolbox.
- `experiments/run_mutation_sensitivity_resumable.m`: recommended formal
  experiment entry point. Each run is saved immediately and the script resumes
  automatically after a MATLAB or computer interruption.
- `experiments/run_parallel_smoke_test.m`: verifies that four workers can
  read the code and instances before the formal parallel experiment starts.
- `experiments/run_factorial_ablation.m`: 1,440 runs for the three-factor
  2^3 factorial ablation experiment.
- `RunConfigurableINSGAIII.m`: single-run entry point. All algorithm switches
  and random seed are explicit arguments.

## Algorithm switches

`useFiveStrategyInitialization`, `useHybridCrossover`, and
`useDynamicElitism` define the three factors of the factorial experiment.
The baseline is all three switches set to `false`. The final INSGA-III
configuration is `110`: five-strategy initialization and hybrid crossover are
enabled, while dynamic elitism is disabled. Configuration `111` is retained
only as a documented candidate in the completed factorial ablation.

## Corrections made to the original release

1. Added the missing `finalvalue1.m` compatibility evaluator.
2. Defined `P_m` as the probability of applying one composite mutation to an
   offspring.
3. Audited the original dynamic-elite trigger. The candidate implementation is
   retained only for factorial-ablation reproducibility and is not part of the
   final INSGA-III configuration because it did not provide an additional
   performance benefit.
4. Added reproducible random seeds, instance paths independent of the current
   working directory, CSV/MAT result logging, and experiment scripts.

Do not report results until the scripts have run successfully on MATLAB and
the generated CSV files have been statistically checked.
