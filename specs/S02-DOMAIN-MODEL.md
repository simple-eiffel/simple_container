# S02: Domain Model - simple_container

## Date: 2026-01-20

## Problem Domain

**simple_container** addresses the problem of performing functional-style operations on Eiffel collections without manual cursor manipulation. Traditional Eiffel iteration requires managing `start`, `forth`, `after` explicitly, which is error-prone and verbose. This library provides declarative operations (filter, map, reduce, partition) using composable query conditions.

The library fills a gap between ISE's basic collections and functional programming patterns common in modern languages (Java Streams, C# LINQ, Python itertools).

## Core Concepts

### 1. Query Condition
A composable boolean predicate that can be applied to collection elements. Supports boolean algebra (AND, OR, NOT) for combining simple conditions into complex ones.

### 2. List Query
A wrapper around a LIST that provides cursor-safe query operations without modifying the original list's cursor state.

### 3. Slice
A lazy view into a portion of an array or list. Does not copy data - references the original source with offset and bounds.

### 4. Set Operations
Mathematical set operations (union, intersection, difference) applied to any ITERABLE, producing ARRAYED_SET results.

### 5. List Extensions
Additional functional operations on lists: partitioning, grouping, reversing, take/drop operations.

### 6. String Conversions
Utilities for converting between collections and string representations (join with separator, split into list).

## Relationships

```
SIMPLE_PREDICATE_CONDITION ──is-a──> SIMPLE_QUERY_CONDITION
SIMPLE_AND_CONDITION ──is-a──> SIMPLE_QUERY_CONDITION
SIMPLE_OR_CONDITION ──is-a──> SIMPLE_QUERY_CONDITION
SIMPLE_NOT_CONDITION ──is-a──> SIMPLE_QUERY_CONDITION

SIMPLE_AND_CONDITION ──has-a──> SIMPLE_QUERY_CONDITION (left, right)
SIMPLE_OR_CONDITION ──has-a──> SIMPLE_QUERY_CONDITION (left, right)
SIMPLE_NOT_CONDITION ──has-a──> SIMPLE_QUERY_CONDITION (operand)

SIMPLE_LIST_QUERY ──uses──> SIMPLE_QUERY_CONDITION
SIMPLE_LIST_QUERY ──wraps──> LIST

SIMPLE_LIST_EXTENSIONS ──uses──> SIMPLE_QUERY_CONDITION
SIMPLE_LIST_EXTENSIONS ──wraps──> LIST

SIMPLE_SLICE ──views──> READABLE_INDEXABLE
SIMPLE_SLICE ──produces──> SIMPLE_SLICE_CURSOR

SIMPLE_SET_OPERATIONS ──consumes──> ITERABLE
SIMPLE_SET_OPERATIONS ──produces──> ARRAYED_SET

SIMPLE_STRING_CONVERSIONS ──consumes──> ITERABLE
SIMPLE_STRING_CONVERSIONS ──produces──> STRING_32 / ARRAYED_LIST
```

## Domain Vocabulary

| Term | Definition |
|------|------------|
| Condition | A boolean predicate that determines if an element satisfies a criterion |
| Predicate | A FUNCTION/PREDICATE agent that evaluates to BOOLEAN |
| Conjuncted | Combined with AND (both must be true) |
| Disjuncted | Combined with OR (either can be true) |
| Negated | Inverted (NOT - true becomes false) |
| Filtered | Elements that satisfy a condition |
| Satisfying | Meeting the requirements of a condition |
| Partition | Split into two groups: those satisfying and those not satisfying |
| Slice | A view into a contiguous portion of a container |
| Cursor-safe | Operations that don't affect the original container's cursor position |
| Lazy evaluation | Computation deferred until result is actually needed |

## Responsibility Allocation

| Class | Primary Responsibility |
|-------|----------------------|
| SIMPLE_QUERY_CONDITION | Define the interface for composable boolean conditions |
| SIMPLE_PREDICATE_CONDITION | Wrap a PREDICATE agent as a query condition |
| SIMPLE_AND_CONDITION | Combine two conditions with logical AND |
| SIMPLE_OR_CONDITION | Combine two conditions with logical OR |
| SIMPLE_NOT_CONDITION | Negate a condition |
| SIMPLE_LIST_QUERY | Provide cursor-safe query operations on lists |
| SIMPLE_LIST_EXTENSIONS | Provide functional operations (partition, take, drop) |
| SIMPLE_SLICE | Provide lazy slice view into indexable containers |
| SIMPLE_SLICE_CURSOR | Enable across-loop iteration over slices |
| SIMPLE_SET_OPERATIONS | Provide set-theoretic operations on collections |
| SIMPLE_STRING_CONVERSIONS | Convert between collections and strings |
| SIMPLE_CURSOR_GUARD | RAII-style cursor position preservation |

## Domain Rules (from Invariants)

1. **Condition operands must exist**: AND/OR/NOT conditions always have non-void operands
2. **Wrapper targets must exist**: Query/Extension wrappers always have non-void target lists
3. **Slice sources must exist**: Slices always reference a valid source container
4. **Slice indices are valid**: start_index <= end_index (can be equal for single-element)
5. **Cursor positions are positive**: Slice cursor position >= 1
6. **Predicates must exist**: Predicate conditions always have non-void predicates

## Open Questions

1. **Missing: Sorting** - No sorted/order_by operation on lists
2. **Missing: Distinct/Unique** - No way to remove duplicates from lists
3. **Missing: Zip** - No way to combine two lists element-by-element
4. **Missing: Flatten** - No way to flatten nested lists
5. **Missing: Window/Chunk** - No sliding window or chunking operations
6. **Missing: Index-aware operations** - No indexed_filter, indexed_map
7. **Missing: Min/Max** - No way to find extrema in lists
8. **Missing: Find index** - No way to find the index of a matching element
9. **Generic type limitation**: Set operations require HASHABLE constraint
10. **No parallel/SCOOP operations**: All operations are sequential
