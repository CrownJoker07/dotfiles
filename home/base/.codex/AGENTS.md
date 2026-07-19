# Global Agent Instructions

## Coding Rules

### Dependency Installation

- Never install dependencies or developer tools globally, system-wide, or into a user-wide environment. This includes commands such as `pip install --user`, global `pip install`, `npm install -g`, `cargo install`, `go install`, and `gem install`.
- Ask the user for explicit permission before running any command that installs or updates dependencies or developer tools.
- Install project dependencies only through the project's existing package manager and project-local isolated environment. For Python, use the project's `.venv`; never install into the system or user Python environment.

### Keep Scope Minimal

- Implement only what the user explicitly requested.
- Do not add related features, future-proofing, configuration, persistence, discovery, batching, or automation unless requested.
- If the user asks for only one capability, the implementation should contain only that capability.

### Prefer Simple APIs

- Keep public APIs direct, readable, and narrowly shaped around the requested use case.
- Do not add overloads, nested return structures, generic options, or batch inputs/outputs for flexibility unless requested.
- If callers can reasonably compose behavior themselves, keep helper utilities focused on the single operation.

### Avoid Premature Abstraction

- Do not create helper functions, classes, interfaces, or layers for one-off or trivial logic.
- Keep simple transformations inline unless extraction clearly removes duplication, handles real complexity, or improves readability.
- Prefer local, direct logic over broad rewrites or new dependencies.

### Match User Intent

- Treat explicit constraints from the user as hard requirements.
- Do not modify existing workflows, entry points, side effects, or integration points unless the request calls for it.
- When the requested change is narrow, avoid touching adjacent behavior.

### Do Not Add Unrequested Defaults

- Do not add sample data, placeholder values, hardcoded defaults, optional parameters, unused constants, or extra request fields unless requested.
- Model only the data and behavior that the implementation actually needs.

### Avoid Hardcoded Special Cases

- Do not add one-off migration, patching, rewriting, or compatibility logic unless the user explicitly asks for that exact behavior.
- Do not silently mutate existing user configuration, project files, or workflows beyond the documented behavior of the command being changed.
- If default behavior needs to change, update the source of truth that creates new defaults instead of adding ad hoc fixes in callers, scripts, or wrappers.
- Prefer explicit commands, clear documentation, or user-edited configuration over hidden automatic rewrites.
- Do not hardcode narrow lists of file extensions, field names, paths, patterns, or observed cases just to handle one specific example.
- If backward compatibility is required, implement it as a deliberate and named API/CLI capability, not as implicit behavior.
- Before adding automatic mutation, ask whether it is explicitly requested, documented, and safe for all existing users. If not, do not add it.

### Validation And Error Handling

- Do not add defensive validation, null/empty checks, fallback branches, retries, normalization, or recovery paths unless requested or required at an external trust boundary.
- Validate inputs once at the boundary. Treat private helper inputs as already validated by their caller, and do not duplicate checks in internal call chains.
- Keep error handling useful for diagnosis, but avoid complex aggregation, retry, fallback, or recovery strategies unless requested.

### Implementation Review

- Before expanding scope, ask whether the added behavior was explicitly requested.
- If a shorter, more direct implementation satisfies the request, prefer it.
