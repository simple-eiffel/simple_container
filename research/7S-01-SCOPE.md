# 7S-01: Scope - simple_container Improvements


**Date**: 2026-01-20

## Date: 2026-01-20

---

## Problem Statement

**In one sentence**: simple_container lacks several common functional programming operations that developers expect from a modern collection library.

**What's wrong today**: The library provides basic filter/map/reduce/partition but is missing:
- Sorting operations (sorted, order_by)
- Distinct/unique filtering
- Zip operations (combining parallel collections)
- Flatten operations (nested list handling)
- Window/chunking operations
- Index-aware operations
- Min/max finding
- Find-index operations

**Who experiences this**: Eiffel developers using simple_container who need these operations must implement them manually or use verbose workarounds.

**Impact**: Reduced productivity; developers may avoid the library for complex use cases.

---

## Target Users

### Primary Users
| User Type | Needs | Pain Level |
|-----------|-------|------------|
| Eiffel developers | Common functional operations | MEDIUM |
| simple_* ecosystem users | Consistent API across libraries | MEDIUM |

### Non-Users
- Developers needing parallel/SCOOP operations (out of scope for this improvement)
- Developers needing database-style joins (different problem domain)

---

## Success Criteria

### MVP (Minimum Viable)
| Criterion | Measure |
|-----------|---------|
| Add highest-value operations | At least 4 new operations |
| All tests pass | 100% test pass rate |
| No breaking changes | Existing API unchanged |

### Full Success
| Criterion | Measure |
|-----------|---------|
| Comprehensive operations | 8+ new operations covering all gaps |
| Full DBC coverage | Contracts on all new features |
| Documentation updated | README and docs reflect additions |

---

## Scope

### In Scope (Candidate Improvements)

| ID | Operation | Priority | Rationale |
|----|-----------|----------|-----------|
| IMP-01 | sorted/order_by | SHOULD | Very common operation, easy to implement |
| IMP-02 | distinct | SHOULD | Common operation, requires HASHABLE |
| IMP-03 | min/max/min_by/max_by | MUST | Fundamental operation, high value |
| IMP-04 | find_index/index_of_first | SHOULD | Often needed, straightforward |
| IMP-05 | zip | COULD | Useful but less common in practice |
| IMP-06 | flatten/flat_map | COULD | Nested list handling |
| IMP-07 | chunked | COULD | Split into fixed-size groups |
| IMP-08 | windowed | COULD | Sliding window operation |
| IMP-09 | indexed_map/indexed_filter | COULD | Index-aware variants |

### Out of Scope
- Parallel/SCOOP operations (requires different architecture)
- Relaxing HASHABLE constraint on set operations (fundamental type system limitation)
- Lazy/stream-based operations (would require rewrite)

---

## Constraints

### Technical Constraints
| Constraint | Impact | Negotiable |
|------------|--------|------------|
| Must maintain void safety | All new features void-safe | NO |
| Must be SCOOP compatible | Use across iteration | NO |
| sorted requires COMPARABLE | Type constraint on sorted | NO |
| distinct requires HASHABLE | Type constraint on distinct | NO |

### Design Constraints
| Constraint | Impact |
|------------|--------|
| Follow existing API patterns | New features match existing style |
| No breaking changes | Existing code must work unchanged |
| Full DBC | Contracts on all new features |

---

## Research Questions

1. What operations are most commonly used in functional programming libraries?
2. How do other languages (Java, C#, Kotlin) implement these operations?
3. Which operations can be added to existing classes vs. require new classes?
4. What are the type constraints for each operation?
5. What edge cases need testing for each operation?
