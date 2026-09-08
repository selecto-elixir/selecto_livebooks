# Livebook relevance review — September 2026

The September review now covers 33 notebooks, with a dedicated action and
domain-contract learning path.

## September 5: application boundary follow-through

Five database-free workbooks close the next practical gaps exposed by the
action/domain track:

| Workbook | Executable boundary |
| --- | --- |
| `selecto_choice_membership_workbook.livemd` | Carries an untrusted lookup value into a typed update; proves the membership resolver receives tenant/filter/record context; rejects missing proof and a stale/cross-tenant value. |
| `selecto_action_form_workbook.livemd` | Exercises Components action normalization, variant inputs, modal request emission, host preview/apply authorization, reload metadata, and denial state without claiming browser rendering. |
| `selecto_action_authorization_lifecycle_workbook.livemd` | Issues a phase-bound grant, consumes it once, rejects replay and altered plans, and expires an unused grant. |
| `selecto_domain_evolution_workbook.livemd` | Builds deterministic consumer releases and classifies expanded bounds as compatible and narrowed modes/bounds as breaking. |
| `selecto_action_observability_workbook.livemd` | Passes a declared audit envelope through preview/execute and records only a simulated committed outcome, distinguishing policy denial and adapter failure. |

These examples deliberately keep host responsibilities visible. Lookup labels
are not mutation proof, modal events do not execute writes, authorization grants
are not durable tokens, relationship diffs do not version ordinary fields, and
an audit envelope is not automatic persistence. The database-free execution
gate now covers 13 notebooks; the PostgreSQL fixture and seeded counts remain
six and 14 respectively.

## September 4: actions and newer domain features

The four new workbooks target implemented APIs in the shared dependency snapshot:

| Workbook | What the reader builds and checks |
| --- | --- |
| `selecto_actions_workbook.livemd` | Named approval/review actions, typed discriminators, required variant inputs, trusted context, opaque plans, preview/apply capability decisions, Components presentation, and concrete bulk cardinality. |
| `selecto_action_execution_workbook.livemd` | A host execution adapter with a native Postgrex connection; preview without writes, authorization rejection, successful transition, repeat/stale/NULL/other-tenant rejection, and rollback when one of two bulk rows matches. |
| `selecto_co_domains_workbook.livemd` | SQL-computed eligibility, hidden selection fields, NULL/missing eligibility, a target-owned lookup view, tenant and active-row filtering, bound prefix search, and invalid/projection-mismatch cases. |
| `selecto_domain_contracts_workbook.livemd` | Colocated write normalization, diagnostic categories, consumer projections, canonical dependency/operation/experience registries, invalid shapes and computed cycles, and deterministic consumer releases. |

All four share the established bootstrap; a small action fixture supplies a
complete domain and five synthetic temporary rows. The two database-free
notebooks are added to the default execution gate, and the other two to the
temporary-table PostgreSQL gate. The index now contains eight database-free,
six temporary-fixture, and 14 seeded reference notebooks.

Important boundaries are demonstrated where they matter: `internal: true` is
a UI hint, lookup results do not authorize a selected value, a capability preview
does not grant later execution, and action guards run in the mutation predicate.
Consumer registry validation checks declaration shapes; it does not discover
providers, render experiences, or certify deployed operation implementations.
The runtime `tenant_required` key remains classified as unknown by the section
registry; the contract notebook explicitly shows that compatibility diagnostic.

The new work does not claim that grouped/co-domain action-input controls have
been implemented in LiveView, or that audit metadata automatically persists an
audit event. The host execution example passes authorization context through
unchanged and leaves authentication, confirmation UI, and audit storage with
the host application.

Verification for these additions used Elixir 1.20 and an isolated PostgreSQL
18.6 cluster. The local default suite passed 33 checks with the database port
deliberately unreachable; the local live gate executed all six temporary-table
notebooks successfully. The new action execution notebook was also rerun after
tightening its cardinality-error assertions. With published dependencies,
`mix deps.get --check-locked` succeeded and `mix test --include postgres` passed
34 checks with the seeded gate excluded. All four additions therefore executed
in both dependency modes. Formatting and whitespace checks passed. The unchanged
14 seeded references were parsed but not re-executed during this addition;
their earlier execution evidence is recorded separately below.

## Audience and decisions

The original 20 workbooks have broad SQL-feature coverage. The main gap was
an approachable path from a domain to an application query, not another SQL
operator catalog. Retain the reference material, but stop presenting the
3,000-plus-line complete guide as the first required exercise.

This review inspected the index, section inventory, setup paths, query helpers,
and implementations, then executed every Elixir cell in all 24 notebooks.
This is not a claim about every database version or rendered Livebook UI.

## Existing workbook inventory

| Original workbook | Relevance and disposition |
| --- | --- |
| `selecto_guide_examples.livemd` | Useful broad reference; link to the short starting path, correct the tour outline, add a unique pagination tie-breaker. Replace the ambiguous untyped `generate_series` call with a table function exposing real named columns. |
| `selecto_selection_shapes_subselects_retargets.livemd` | High-value application material: distinguish flat fan-out from nested collections and target-root filtering. Retain prominently. |
| `selecto_updato_feature_tour.livemd` | Retain: trusted context, declared writes, upsert policy and real rollback checks; keep the live gate. |
| `selecto_updato_nested_writes_workbook.livemd` | Retain: generated ownership keys, atomic graphs and owned-set synchronization; keep separate from reads. |
| `selecto_strict_mode_workbook.livemd` | Retain as a safety prerequisite for externally driven queries; execute without a database and describe the runtime accurately. |
| `selecto_verification_workbook.livemd` | Retain for maintainers and assurance work, not beginner onboarding. Move the non-connecting models into the default executable gate. Preserve bounded-proof limits. |
| `selecto_components_analytics_workbook.livemd` | Retain for UI authors; compile/state examples do not constitute a rendered LiveView test. Execute the cells in the default gate. |
| `selecto_domain_extensions_workbook.livemd` | Retain for domain authors; remove unnecessary Repo startup, repair explicit view-adapter/refresh APIs and materialized-view index guidance. Compile DDL, never publish it in the notebook. |
| `selecto_filtering_system_workbook.livemd` | Core reference. Align the reference answer with the stated challenge; replace row-count similarity with column and duplicate-aware comparison. Assert the matching answer and reject equal-count, different-multiplicity rows. |
| `selecto_group_by_aggregates_workbook.livemd` | Retain: reporting grain, aggregate filters and subtotal rows are broadly useful. PostgreSQL-specific ROLLUP notes are not cross-backend guarantees. |
| `selecto_ctes_workbook.livemd` | Retain as advanced composition/recursion reference. Tiny-dataset EXPLAIN comparisons are diagnostic examples, not performance rankings. |
| `selecto_other_joins_workbook.livemd` | Retain as advanced reference; dynamic join authoring must not obscure the normal automatic, domain-declared join path. |
| `selecto_domain_join_types_workbook.livemd` | Retain as specialist reference. Import expression macros before use; the old concatenated runner hid this cell-order bug. Marker inspection is distinct from executing hierarchy queries. |
| `selecto_set_operations_workbook.livemd` | Retain: operand filters, duplicates, parameter numbering and outer composition are common correctness traps. |
| `selecto_window_functions_workbook.livemd` | Retain: ranked analytics, frames and running totals complement ordinary aggregates. |
| `selecto_json_operations_workbook.livemd` | Retain as PostgreSQL-specific reference. Use semantic domain type `:json` for structured paths, proper JSON aggregate selectors, and alias-aware `:maps` output. Compare ordered rows, not just counts. |
| `selecto_array_unnest_lateral_workbook.livemd` | Retain for PostgreSQL collection expansion; pay attention to empty collections and parent row preservation. |
| `selecto_case_expressions_workbook.livemd` | Retain: business buckets, nullable cases and business-priority sorting. |
| `selecto_values_lookup_workbook.livemd` | Retain: small inline lookup relations. Correct EXPLAIN ANALYZE wording: it executes queries, not merely estimates planning cost. |
| `selecto_output_formats_execution_workbook.livemd` | Retain: formats and exports matter. Use a native Postgrex connection for cursor execution, assert streamed rows, close it, and document the pinned nested payload. Explain fetched-result streams and measurement limits. Use unique, exclusive export files. |

No existing workbook is removed. Their runtime/data requirements are now
explicit in the README, alongside direct links and a recommended reading order.

## Added application workflows

| Gap | New workbook | Executable evidence |
| --- | --- | --- |
| Minimal entry point and automatic joins | `selecto_first_query_workbook.livemd` | Root-only SQL has no joins; selection/filter/order activate the needed customer join only; immutable branches and hostile bound values. |
| Reusable query intent | `selecto_query_library_workbook.livemd` | DSL segments/projections/orderings/views, typed parameter casting/rejection, required filters/selections, and saved-request reconstruction. No storage service is implied. |
| Stable page boundaries | `selecto_pagination_workbook.livemd` | Real PostgreSQL ties, first/final/empty pages, look-ahead cursor, input validation, and offset duplication after a controlled insertion. |
| Read-side tenant enforcement | `selecto_tenant_reads_workbook.livemd` | Missing/unapplied/mismatched scope, hidden and other-tenant rows, optional OR/equality predicates, caller SQL rejection, independent tenant queries. |

The live additions use a single Postgrex connection and deterministic temporary
tables. DDL/DML belongs only to fixture setup and the controlled insertion;
the application query examples use Selecto. The final cell closes the session.

## Setup and verification repairs

- The notebook bootstrap and app previously selected different standalone
  revisions (and different PostgreSQL repository owners). One shared file now
  pins published revisions, with a regression checking both consumers.
- Default `mix test` advertised no database requirement while its alias invoked
  `ecto.create`/`ecto.migrate` and the app started a Repo. The alias is removed
  and test configuration disables automatic Repo startup. Database tests are
  explicit and require an existing disposable database.
- Dev setup now honors the same database environment variables as the notebook
  bootstrap, preventing accidental setup against a different database.
- The shared bootstrap's retarget smoke check accidentally passed a runtime
  context where a configured Selecto query was required. Its assignment is fixed.
- The runner now evaluates actual cells sequentially while preserving bindings,
  imports and aliases. It identifies failures by cell; runner tests cover state
  propagation and early failure. Six database-free workbooks run by default;
  four isolated PostgreSQL workbooks run in the opt-in gate. A separate seeded
  gate executes the remaining 14 references and rejects known unexpected-error
  markers, including database `QUERY ERROR` messages caught by notebook helpers.
- New examples assert outcomes. Historical exploratory cells may catch and
  print errors; syntax checks or process completion alone do not certify their
  SQL behavior. Repository tests, finite models, live fixtures, and UI rendering
  remain separate evidence categories.

## Adapter follow-up exposed by the review

The pinned PostgreSQL cursor callback does not handle an Ecto Repo supervisor
as a native connection: enumeration timed out. A real Postgrex connection works,
but the current executor wraps the adapter's `{row, columns}` inside another
`{payload, [], aliases}` tuple. The workbook now shows and tests that shape
explicitly. Normalizing this public contract belongs in the shared executor/
adapter and its cross-adapter tests; this review does not patch those sibling
repositories or claim Ecto cursor support was repaired.

## Verification record

Executed with Elixir 1.20 and PostgreSQL 18.6 (Postgres.app), using a new isolated
cluster and disposable review database. No existing application database was
seeded or changed. Published dependency SHAs were checked against their remotes.

| Check | Result |
| --- | --- |
| Default suite with database port deliberately unreachable | 31 passed, 2 opt-in tests excluded; all six database-free notebooks executed |
| Full suite, sibling dependencies | 33 passed; all 24 notebooks executed |
| Full suite, published Git-pinned dependencies | 33 passed; all 24 notebooks executed |
| Final filtering challenge/assertion refinement | Re-executed successfully in both dependency modes |
| `mix format --check-formatted` and `git diff --check` | Passed |

The full suite means `mix test --include postgres --include seeded`. Its two
opt-in tests run four temporary-fixture and 14 seeded notebooks respectively;
the six database-free notebooks have individual execution tests. The counts
include the repository's API/integrity/runner regressions and one doctest, not
33 separate notebooks. The runner uses fresh VMs and sequential cells; interactive
Kino controls, browser rendering, all SQL semantics, load, and other adapters
remain outside this execution evidence.

## Deliberate boundaries

- Do not add speculative framework, dashboard, federation, or unimplemented
  cross-backend features just to fill the index. The source of truth is the
  checked-in public API and tests.
- Multi-database portability needs adapter-specific execution coverage; these
  live additions validate PostgreSQL only.
- Pagination is an application recipe, not snapshot isolation or a cursor-signing
  service. Tenant tests cover specified cases, not arbitrary host code or all
  possible relationship policies.
- Larger exports, query-plan regressions and high-volume performance need a
  controlled benchmark dataset. Tiny fixtures are for correctness.
