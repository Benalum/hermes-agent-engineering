# Testing the factory

1. `./scripts/smoke_test.sh`
2. `./scripts/install_profiles.sh`
3. `hermes profile list`
4. Create a disposable public project:

```bash
./scripts/create_project.sh hermes-factory-test "Hermes Factory Test" "Small calculator REST API used to validate multi-agent orchestration"
```

5. `hermes gateway start` and `hermes dashboard`.
6. Set that board's **Project Directory** to the generated local repo path.
7. Let the `project-manager` kickoff task run.

Expected first dependency shape:

```text
architecture/research → implementation → testing → review → documentation
```

Use worktree workspaces for coding tasks. Pin different models on comparable task types if you want an A/B comparison; avoid inferring a winner from a single run.
