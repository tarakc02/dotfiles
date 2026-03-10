---
name: hrdag-workflow
description: Task-based workflow for data processing pipelines. Provides structure conventions for organizing data analysis work into discrete tasks with standard directories (src/, input/, output/) and Makefile orchestration. Use when working on HRDAG-style data projects, understanding pipeline structures, or when other data processing skills need context about how tasks and pipelines are organized.
---

# HRDAG Task-Based Workflow

Data processing work is divided into discrete **tasks** - single units of work that transform inputs into outputs.

## Task Structure

Every task contains:

```
task-name/
├── Makefile      # defines how to run the task and its dependencies
├── src/          # code that performs the task
├── input/        # (if applicable) data from external sources
└── output/       # built by the task, consumed by downstream tasks
```

If a task takes its input from another task in the same repo, then we use
**relative paths in the makefile** to refer to dependencies in the upstream
task's `output/` directory.

Optional directories:
- `hand/` - configuration files or hand-edited files
- `docs/` - documentation about the task
- `note/` - notebooks (jupyter, rmarkdown) for exploration
- `frozen/` - "frozen" copies of data (e.g., hand-modified Excel files)

### Key Principles

1. **Tasks are self-contained** - all code in `src/`, all outputs in `output/`
2. **Outputs are reproducible** - running `make` rebuilds `output/` from `src/` and `input/`
3. **No data in git** - only code and symlinks; large data lives outside the repo

## Pipeline Structure

Tasks chain together via Makefiles. Pipelines conventionally start with `import` and end with `export`:

```
pipeline-name/
├── Makefile      # orchestrates subtasks
├── import/       # brings data into the pipeline (often just symlinks to another task's export/)
├── clean/        # data cleaning
├── transform/    # data transformation
└── export/       # final output (often symlinks to a common location)
```

### Pipeline Makefile Pattern

```makefile
.PHONY: all import clean transform export

all: export

import:
	cd $@ && make

clean: import
	cd $@ && make

transform: clean
	cd $@ && make

export: transform
	cd $@ && make
```

Each target depends on its predecessor, ensuring tasks run in order.

## Task Makefile Pattern

```makefile
# dependencies pulled from elsewhere in the repo
input := ../../upstream/other-task/export/output/data.csv

.PHONY: all clean

all: output/result.parquet

clean:
	rm -r output/*

output/result.parquet: src/process.py $(input)
    mkdir -p output
	python $< \
        --input $(input) \
        --output $@

```

### Makefile Conventions

- First target is `all` (default when running `make`)
- Use `.PHONY` for targets that aren't files
- Input files depend on upstream task outputs or external data
- Output files depend on both code (`src/`) and data (`input/`)

## Creating New Tasks

```bash
$ mkdir -p clean-records/{src,input,output}/
```

Then add a Makefile defining how to run the task.

## Directory Navigation

When exploring an HRDAG-style project:
1. Look at top-level Makefile to understand pipeline order
2. Check `import/` to see where data originates
3. Check `export/` to see final outputs
4. Follow symlinks in `input/` directories to trace data lineage
