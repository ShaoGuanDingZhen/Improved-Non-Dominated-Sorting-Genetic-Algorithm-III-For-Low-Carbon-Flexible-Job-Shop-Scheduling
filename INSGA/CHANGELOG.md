# Revision changelog

## Added

- `finalvalue1.m`: missing concatenated-chromosome objective evaluator.
- `DefaultExperimentConfig.m`: one source of truth for experimental settings.
- `RunConfigurableINSGAIII.m`: reproducible algorithm entry point.
- `InitializeRandomFeasible.m` and `CrossoverBaseline.m`: controls required
  for fair ablation variants.
- `CalculateDynamicEliteCount.m` and `SelectEliteArchive.m`: documented,
  active implementation of dynamic elitism.
- `ComputeFixedReferenceHV.m` and `ComputeBatchHV.m`: shared-reference
  hypervolume computation for statistically comparable experiment results.
- `experiments/run_validation.m`, `run_mutation_sensitivity.m`, and
  `run_factorial_ablation.m`: reviewer-response experimental workflows.
- `run_mutation_sensitivity_parallel.m`: four-worker parallel workflow for
  the formal mutation-probability experiment.
- `run_mutation_sensitivity_resumable.m`: per-run checkpointing and automatic
  resume for the 600-run mutation-probability experiment.

## Changed

- Final INSGA-III is now configuration `110`: five-strategy initialization
  and hybrid crossover enabled, dynamic elitism disabled. This setting follows
  the completed 1,440-run paired factorial ablation.

- `Mutate.m`: fixes two machine-mutation comparisons. The original code
  compared a machine gene at the wrong chromosome position to a candidate-list
  index rather than to the candidate machine identifier.

## Kept unchanged

- All original source and data files remain under `源代码`.
