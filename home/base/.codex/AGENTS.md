# Global Agent Instructions

## Coding Rules

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

### Validation And Error Handling

- Do not add defensive validation, null/empty checks, fallback branches, retries, normalization, or recovery paths unless requested or required at an external trust boundary.
- Validate inputs once at the boundary. Treat private helper inputs as already validated by their caller, and do not duplicate checks in internal call chains.
- Keep error handling useful for diagnosis, but avoid complex aggregation, retry, fallback, or recovery strategies unless requested.

### Implementation Review

- Before expanding scope, ask whether the added behavior was explicitly requested.
- If a shorter, more direct implementation satisfies the request, prefer it.
