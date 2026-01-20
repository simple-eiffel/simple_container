# 7S-04: Design Decisions - simple_container Improvements

## Date: 2026-01-20

---

## Decision Summary

| ID | Decision | Option Chosen | Rationale |
|----|----------|---------------|-----------|
| D-01 | Where to add features | Existing + New classes | Type constraints require separate classes |
| D-02 | Return type for empty | Detachable (Void) | Matches Eiffel patterns |
| D-03 | Index return for not found | Return 0 | Standard Eiffel convention |
| D-04 | Sorted implementation | Copy and sort | Don't modify original |

---

## D-01: Where to Add Features

### Options

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A: All in SIMPLE_LIST_EXTENSIONS | Add all to existing class | Simple, consistent | Can't add type constraints |
| B: Existing + New constrained classes | Split by constraint needs | Clean type safety | More classes |
| C: Redesign with inheritance | Base class + constrained descendants | Flexible | Breaking change |

### Decision: **Option B** - Existing + New constrained classes

**Rationale**:
- Features like sorted_by need COMPARABLE on key type
- Features like distinct need HASHABLE on element type
- Cannot add constraints to existing generic class without breaking API
- Adding new classes is non-breaking

### Implementation

```
SIMPLE_LIST_EXTENSIONS [G]           -- Existing (no constraint)
  + min_by, max_by                   -- Works with any G, comparator via agent
  + index_of_first, index_of_last   -- Works with any G
  + zip                              -- Works with any G
  + chunked, windowed               -- Works with any G

SIMPLE_SORTABLE_LIST_EXTENSIONS [G]  -- NEW (key must be COMPARABLE)
  + sorted_by (key returns COMPARABLE)
  + sorted_by_descending

SIMPLE_HASHABLE_LIST_EXTENSIONS [G -> HASHABLE]  -- NEW (G must be HASHABLE)
  + distinct
  + distinct_by
```

---

## D-02: Return Type for Empty Collections

### Options

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A: Detachable (Void) | Return Void if empty | Safe, explicit | Caller must check |
| B: Raise exception | Precondition or exception | Forces non-empty | Unexpected failures |
| C: Return default | Return default value | Always returns | Wrong for many types |

### Decision: **Option A** - Detachable (Void)

**Rationale**:
- Matches Kotlin's OrNull pattern (minOrNull, maxOrNull)
- Matches existing first_satisfying pattern
- Void safety handles this cleanly in Eiffel
- No surprise exceptions

**Pattern**:
```eiffel
min_by (a_selector: FUNCTION [G, COMPARABLE]): detachable G
    -- Returns Void if target is empty
```

---

## D-03: Index Return for Not Found

### Options

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A: Return 0 | 0 means not found | Standard Eiffel | Must check for 0 |
| B: Return -1 | -1 means not found | Common in other languages | Not Eiffel convention |
| C: Detachable INTEGER | Void if not found | Type-safe | Awkward for expanded |

### Decision: **Option A** - Return 0

**Rationale**:
- Standard Eiffel convention (LIST.index_of returns 0 for not found)
- 1-based indexing means 0 is invalid index anyway
- Simple and predictable

---

## D-04: Sorted Implementation

### Options

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A: Copy and sort | Create new list, sort it | Functional, immutable | Memory allocation |
| B: Sort in place | Modify original | Efficient | Breaks functional pattern |
| C: Lazy sorting | Return sorted view | Very efficient | Complex to implement |

### Decision: **Option A** - Copy and sort

**Rationale**:
- Matches functional pattern (all other operations return new collections)
- Predictable behavior
- Original list unchanged
- Consistent with take, drop, filtered, etc.

---

## D-05: Sorting Algorithm

### Decision: Use SORTER from ISE base library

**Rationale**:
- Well-tested implementation
- No need to reinvent
- QUICK_SORTER for general use

**Implementation**:
```eiffel
sorted_by (a_key: FUNCTION [G, COMPARABLE]): ARRAYED_LIST [G]
  local
    l_sorter: QUICK_SORTER [G]
  do
    -- Copy to result
    create Result.make_from_iterable (target)
    -- Sort using comparator
    create l_sorter.make (agent compare_by_key (?, ?, a_key))
    l_sorter.sort (Result)
  end
```

---

## Trade-offs Accepted

### Trade-off 1: New Classes vs Clean Design
- **Accepted**: Multiple classes for different constraints
- **Alternative**: Single class with runtime checks
- **Reason**: Type safety at compile time is worth extra classes

### Trade-off 2: Copying vs Efficiency
- **Accepted**: All operations create new collections
- **Alternative**: In-place modifications
- **Reason**: Functional style, predictability, thread-safety

### Trade-off 3: No Lazy Evaluation
- **Accepted**: Eager evaluation throughout
- **Alternative**: Stream-based lazy evaluation
- **Reason**: Complexity not justified for typical use cases

---

## Architecture Impact

```
                    ┌─────────────────────────┐
                    │   SIMPLE_LIST_QUERY     │
                    │       [G]               │
                    │  (filter, map, fold)    │
                    └─────────────────────────┘
                              │
            ┌─────────────────┼─────────────────┐
            ▼                 ▼                 ▼
┌───────────────────┐ ┌───────────────────┐ ┌───────────────────┐
│ SIMPLE_LIST_      │ │ SIMPLE_SORTABLE_  │ │ SIMPLE_HASHABLE_  │
│ EXTENSIONS [G]    │ │ LIST_EXTENSIONS   │ │ LIST_EXTENSIONS   │
│                   │ │ [G]               │ │ [G -> HASHABLE]   │
│ +min_by, max_by   │ │                   │ │                   │
│ +index_of_first   │ │ +sorted_by        │ │ +distinct         │
│ +zip, chunked     │ │ +sorted_descending│ │ +distinct_by      │
│ +windowed         │ │                   │ │                   │
└───────────────────┘ └───────────────────┘ └───────────────────┘
```
