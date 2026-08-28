# Final Auth Tenant-Isolation Staging Test Report

Date: 2026-08-28
Project: `Menu` / Supabase project `ebirwuigujqosfarqmqa`
Scope: authorization QA only; no V1.1 features added.

## Executive conclusion

The anonymous public isolation remediation is working, and the authenticated tenant predicates were corrected after the policy inventory exposed tautological comparisons in the branch, category, product, and analytics policies. The final Supabase security advisor returned `lints: []`.

A complete user-level Auth staging test could **not** be executed because the available Supabase integration exposes database/project operations but no Auth admin operation for creating temporary users, and no temporary credentials were supplied. No users were fabricated, no production credentials were used, and no customer data was changed.

Tenant-boundary RLS is structurally corrected and suitable for a controlled first onboarding only after one authenticated staging pass. The current `owner`/`admin`/`editor` role column is **not enforced differently**: all three roles currently receive the same tenant-scoped CRUD permissions. If least-privilege role separation is a launch requirement, that must be fixed before selling.

## Test matrix

| # | Test | Result | Evidence / limitation |
|---:|---|---|---|
| 1 | User A reads/manages AL MAS according to role | NOT RUN | No safe temporary Auth account or Auth-admin connector was available. Policy structure is tenant-scoped. |
| 2 | User A cannot read private/admin Alsakhrah data | NOT RUN | Requires an authenticated User A JWT. Corrected policies compare rows to `tenant_members.tenant_id`. |
| 3 | User A cannot INSERT/UPDATE/DELETE Alsakhrah products | NOT RUN | Requires authenticated mutation requests. Product policies now compare against `products.tenant_id`. |
| 4 | User A cannot modify Alsakhrah branches | NOT RUN | Requires authenticated mutation requests. Branch policies now compare against `branches.tenant_id`. |
| 5 | User A cannot modify Alsakhrah categories | NOT RUN | Requires authenticated mutation requests. Category policies now compare against `categories.tenant_id`. |
| 6 | User B cannot read/manage private/admin AL MAS data | NOT RUN | Requires an authenticated User B JWT. Same corrected membership predicate applies. |
| 7 | User B cannot INSERT/UPDATE/DELETE AL MAS products | NOT RUN | Requires authenticated mutation requests. Product writes are membership-scoped. |
| 8 | User B cannot modify AL MAS branches | NOT RUN | Requires authenticated mutation requests. Branch writes are membership-scoped. |
| 9 | User B cannot modify AL MAS categories | NOT RUN | Requires authenticated mutation requests. Category writes are membership-scoped. |
| 10 | Direct authenticated REST/PostgREST requests | NOT RUN | No temporary authenticated sessions were available. Anonymous direct base-table reads return empty arrays. |
| 11 | ID manipulation using another tenant's `tenant_id` / `branch_id` | NOT RUN | Requires authenticated sessions. `WITH CHECK` predicates now reference the outer target row's tenant ID. |
| 12 | Storage isolation for authenticated writes | NOT RUN | No authenticated upload sessions were available. Live policies require the first path segment to equal a tenant UUID belonging to `auth.uid()`. |
| 13 | `tenant_members` cannot be manipulated by another member | PASS (policy review) | No INSERT/UPDATE/DELETE policy exists for `tenant_members`; SELECT is limited to `user_id = auth.uid()`. A JWT mutation test remains not run. |
| 14 | owner/admin/editor permissions differ as intended | FAIL (design gap) | The `role` column exists, but current policies and admin logic check membership only. `owner`, `admin`, and `editor` are not differentiated. |

## Direct anonymous regression tests

| Scenario | Result |
|---|---|
| `get_public_menu(almas, malaz)` | HTTP 200 with AL MAS payload |
| `get_public_menu(alsakhrah, malaz)` | HTTP 200 with Alsakhrah payload |
| `get_public_menu(almas, main)` | HTTP 200 with `null` |
| Unknown tenant RPC | HTTP 200 with `null` |
| Direct anonymous `tenants`, `branches`, `categories`, `products` reads | HTTP 200 with `[]` |
| Direct anonymous `menu_events` insert | HTTP 401 / RLS rejection |
| Invalid product analytics RPC | HTTP 400 `invalid product` |
| Public RPC security advisor | `lints: []` |
| JavaScript/browser regression | Passed for AL MAS, Alsakhrah, invalid routes, and admin shell |

## Findings and remediation

The first live policy inventory revealed a material defect in several authenticated policies: expressions such as `tm.tenant_id = tm.tenant_id` were tautologies because the outer table column was not qualified. This was remediated in `auth_rls_tenant_qualification_fix.sql` and applied to the live project. The corrected policies now compare `tm.tenant_id` to `branches.tenant_id`, `categories.tenant_id`, `products.tenant_id`, or `menu_events.tenant_id` as appropriate.

The public RPCs use `SECURITY INVOKER` with transaction-local context values. Anonymous base-table reads require the context set by the RPC, and direct anonymous reads therefore return no rows. Analytics direct inserts are denied; the RPC validates tenant, active branch, product ownership, category ownership, availability, and event type.

## Onboarding decision

**Tenant isolation:** structurally safe after the live policy correction and anonymous/API tests.
**Final Auth authorization sign-off:** not complete, because authenticated test users could not be created safely in this environment.
**First-customer onboarding:** proceed only with a staging Auth pass using two dedicated temporary users, not production credentials. Do not sell role-sensitive access until the owner/admin/editor behavior is explicitly implemented or the product is intentionally documented as membership-only access.

## Cleanup and credential handling

No temporary users were created, so there were no accounts to delete or disable. No credentials were written to disk, committed to GitHub, or exposed in output. No production customer records were modified.

## Exact files changed

- `app.js` — secure public RPC reads, analytics RPC calls, explicit local-demo fallback label.
- `supabase-schema.sql` — reproducible invoker/RLS remediation and corrected authenticated predicates.
- `public_security_rpc.sql` — live public RPC and context-scoped RLS migration.
- `auth_rls_tenant_qualification_fix.sql` — corrected authenticated tenant predicates.
- `security_qa.md` — direct API security evidence.
- `README.md` — security architecture and test notes.
- `final_auth_tenant_isolation_report.md` — this report.

## Final required action

Run the same matrix with two dedicated staging Auth users and real JWTs in a staging project. Use one AL MAS membership and one Alsakhrah membership, attempt reads and mutations against the opposite tenant, attempt path/ID manipulation, upload to both tenant UUID prefixes, and verify that all cross-tenant operations fail. Then delete or disable both staging users and remove their membership rows.
