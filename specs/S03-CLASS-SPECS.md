# S03: Class Specifications - simple_container

## Date: 2026-01-20

---

## SIMPLE_QUERY_CONDITION [G]

### Identity
- **Role**: ABSTRACT (deferred)
- **Domain Concept**: Query Condition
- **Lines**: 31

### Purpose
Abstract composable boolean condition for filtering collection elements. Defines the interface for the Composite pattern allowing conditions to be combined using boolean algebra.

### Queries
| Feature | Returns | Purpose | Contracts |
|---------|---------|---------|-----------|
| `satisfied_by (a_item: G)` | BOOLEAN | Check if item satisfies condition | deferred |

### Composition (Factory Methods)
| Feature | Returns | Purpose | Contracts |
|---------|---------|---------|-----------|
| `conjuncted alias "and" (a_other)` | SIMPLE_AND_CONDITION [G] | Create AND combination | deferred |
| `disjuncted alias "or" (a_other)` | SIMPLE_OR_CONDITION [G] | Create OR combination | deferred |
| `negated alias "not"` | SIMPLE_NOT_CONDITION [G] | Create negation | deferred |

### Invariants
None (deferred class)

### Contract Coverage
- Deferred class, contracts defined in descendants: 100%

---

## SIMPLE_PREDICATE_CONDITION [G]

### Identity
- **Role**: ENGINE
- **Domain Concept**: Predicate Condition
- **Lines**: 71

### Purpose
Wraps a PREDICATE agent as a query condition. Primary way users create conditions.

### Creation
| Procedure | Preconditions | Postconditions |
|-----------|---------------|----------------|
| `make (a_predicate: PREDICATE [G])` | predicate_exists: a_predicate /= Void | predicate_set: predicate = a_predicate |

### Queries
| Feature | Returns | Purpose | Contracts |
|---------|---------|---------|-----------|
| `satisfied_by (a_item: G)` | BOOLEAN | Evaluate predicate on item | Pure |

### Composition
| Feature | Preconditions | Postconditions |
|---------|---------------|----------------|
| `conjuncted (a_other)` | other_exists: a_other /= Void | result_exists: Result /= Void |
| `disjuncted (a_other)` | other_exists: a_other /= Void | result_exists: Result /= Void |
| `negated` | None | result_exists: Result /= Void |

### Invariants
```eiffel
predicate_exists: predicate /= Void
```

### Contract Coverage: STRONG (100%)

---

## SIMPLE_AND_CONDITION [G]

### Identity
- **Role**: ENGINE
- **Domain Concept**: Conjuncted Condition
- **Lines**: 78

### Purpose
Represents logical AND of two conditions. Part of Composite pattern.

### Creation
| Procedure | Preconditions | Postconditions |
|-----------|---------------|----------------|
| `make (a_left, a_right: SIMPLE_QUERY_CONDITION [G])` | left_exists, right_exists | left_set, right_set |

### Queries
| Feature | Returns | Purpose |
|---------|---------|---------|
| `satisfied_by (a_item: G)` | BOOLEAN | True iff left AND right satisfied |

### Invariants
```eiffel
left_exists: left /= Void
right_exists: right /= Void
```

### Contract Coverage: STRONG (100%)

---

## SIMPLE_OR_CONDITION [G]

### Identity
- **Role**: ENGINE
- **Domain Concept**: Disjuncted Condition
- **Lines**: 78

### Purpose
Represents logical OR of two conditions. Part of Composite pattern.

### Creation
| Procedure | Preconditions | Postconditions |
|-----------|---------------|----------------|
| `make (a_left, a_right: SIMPLE_QUERY_CONDITION [G])` | left_exists, right_exists | left_set, right_set |

### Queries
| Feature | Returns | Purpose |
|---------|---------|---------|
| `satisfied_by (a_item: G)` | BOOLEAN | True iff left OR right satisfied |

### Invariants
```eiffel
left_exists: left /= Void
right_exists: right /= Void
```

### Contract Coverage: STRONG (100%)

---

## SIMPLE_NOT_CONDITION [G]

### Identity
- **Role**: ENGINE
- **Domain Concept**: Negated Condition
- **Lines**: 71

### Purpose
Represents logical NOT of a condition. Part of Composite pattern.

### Creation
| Procedure | Preconditions | Postconditions |
|-----------|---------------|----------------|
| `make (a_operand: SIMPLE_QUERY_CONDITION [G])` | operand_exists | operand_set |

### Queries
| Feature | Returns | Purpose |
|---------|---------|---------|
| `satisfied_by (a_item: G)` | BOOLEAN | True iff operand NOT satisfied |

### Invariants
```eiffel
operand_exists: operand /= Void
```

### Contract Coverage: STRONG (100%)

---

## SIMPLE_LIST_QUERY [G]

### Identity
- **Role**: FACADE
- **Domain Concept**: List Query
- **Lines**: 128

### Purpose
Provides cursor-safe query operations on lists using `across` iteration. Does not modify original list's cursor state.

### Creation
| Procedure | Preconditions | Postconditions |
|-----------|---------------|----------------|
| `make (a_list: LIST [G])` | list_exists | target_set |

### Queries
| Feature | Returns | Preconditions | Postconditions |
|---------|---------|---------------|----------------|
| `filtered (a_condition)` | ARRAYED_LIST [G] | condition_exists | result_exists, bounded |
| `first_satisfying (a_condition)` | detachable G | condition_exists | None |
| `all_satisfy (a_condition)` | BOOLEAN | condition_exists | None |
| `any_satisfies (a_condition)` | BOOLEAN | condition_exists | None |
| `count_satisfying (a_condition)` | INTEGER | condition_exists | non_negative, bounded |
| `mapped (a_function)` | ARRAYED_LIST [ANY] | function_exists | result_exists, same_count |
| `folded (a_initial, a_combiner)` | detachable ANY | combiner_exists | None |

### Invariants
```eiffel
target_exists: target /= Void
```

### Contract Coverage: STRONG (100%)

---

## SIMPLE_LIST_EXTENSIONS [G]

### Identity
- **Role**: FACADE
- **Domain Concept**: List Extensions
- **Lines**: 163

### Purpose
Provides functional-style extension operations on lists: partitioning, grouping, reversing, take/drop operations.

### Creation
| Procedure | Preconditions | Postconditions |
|-----------|---------------|----------------|
| `make (a_list: LIST [G])` | list_exists | target_set |

### Queries
| Feature | Returns | Preconditions | Postconditions |
|---------|---------|---------------|----------------|
| `partition (a_condition)` | TUPLE [satisfying, not_satisfying] | condition_exists | result_exists, total_preserved |
| `group_by (a_key_function)` | HASH_TABLE [ARRAYED_LIST [G], HASHABLE] | key_function_exists | result_exists |
| `reversed` | ARRAYED_LIST [G] | None | result_exists, same_count |
| `take (n)` | ARRAYED_LIST [G] | non_negative | result_exists, bounded_count |
| `drop (n)` | ARRAYED_LIST [G] | non_negative | result_exists, correct_count |
| `take_while (a_condition)` | ARRAYED_LIST [G] | condition_exists | result_exists, bounded |
| `drop_while (a_condition)` | ARRAYED_LIST [G] | condition_exists | result_exists, bounded |

### Invariants
```eiffel
target_exists: target /= Void
```

### Contract Coverage: STRONG (100%)

---

## SIMPLE_SLICE [G]

### Identity
- **Role**: FACADE
- **Domain Concept**: Slice
- **Lines**: 170

### Purpose
Lazy view into a portion of a READABLE_INDEXABLE. Does not copy data - references original source with offset and bounds. Supports `across` iteration.

### Creation
| Procedure | Preconditions | Postconditions |
|-----------|---------------|----------------|
| `make (a_source, a_start, a_end)` | source_exists, valid_start, valid_end, valid_range | source_set, start_set, end_set |
| `make_from_end (a_source, a_start_from_end, a_count)` | source_exists, non_negative_offset, positive_count, valid_range | source_set |

### Queries
| Feature | Returns | Preconditions | Postconditions |
|---------|---------|---------------|----------------|
| `item alias "[]" (i)` | G | valid_index | None |
| `first` | G | not_empty | None |
| `last` | G | not_empty | None |
| `count` | INTEGER | None | non_negative |
| `is_empty` | BOOLEAN | None | definition |
| `valid_index (i)` | BOOLEAN | None | None |
| `new_cursor` | SIMPLE_SLICE_CURSOR [G] | None | None |
| `to_array` | ARRAY [G] | None | result_exists, same_count |
| `to_list` | ARRAYED_LIST [G] | None | result_exists, same_count |
| `sub_slice (a_start, a_end)` | SIMPLE_SLICE [G] | valid_start, valid_end, valid_range | result_exists, correct_count |

### Invariants
```eiffel
source_exists: source /= Void
count_consistent: count = (end_index - start_index + 1).max (0)
```

### Contract Coverage: STRONG (100%)

---

## SIMPLE_SLICE_CURSOR [G]

### Identity
- **Role**: HELPER
- **Domain Concept**: Slice Cursor
- **Lines**: 69

### Purpose
Iteration cursor for SIMPLE_SLICE. Enables `across` loop iteration over slices.

### Creation
| Procedure | Preconditions | Postconditions |
|-----------|---------------|----------------|
| `make (a_slice: SIMPLE_SLICE [G])` | slice_exists | slice_set, position_at_start |

### Queries
| Feature | Returns | Preconditions |
|---------|---------|---------------|
| `item` | G | not_after |
| `after` | BOOLEAN | None |

### Commands
| Feature | Preconditions | Postconditions |
|---------|---------------|----------------|
| `forth` | not_after | position_advanced |

### Invariants
```eiffel
slice_exists: slice /= Void
position_positive: position >= 1
```

### Contract Coverage: STRONG (100%)

---

## SIMPLE_SET_OPERATIONS [G -> HASHABLE]

### Identity
- **Role**: FACADE
- **Domain Concept**: Set Operations
- **Lines**: 110

### Purpose
Provides mathematical set operations on any ITERABLE collections. Stateless utility class.

### Queries
| Feature | Returns | Preconditions | Postconditions |
|---------|---------|---------------|----------------|
| `union (a_first, a_second)` | ARRAYED_SET [G] | first_exists, second_exists | result_exists |
| `intersection (a_first, a_second)` | ARRAYED_SET [G] | first_exists, second_exists | result_exists |
| `difference (a_first, a_second)` | ARRAYED_SET [G] | first_exists, second_exists | result_exists |
| `symmetric_difference (a_first, a_second)` | ARRAYED_SET [G] | first_exists, second_exists | result_exists |
| `is_subset (a_candidate, a_superset)` | BOOLEAN | candidate_exists, superset_exists | None |
| `is_disjoint (a_first, a_second)` | BOOLEAN | first_exists, second_exists | None |

### Invariants
None (stateless)

### Contract Coverage: MODERATE (preconditions only, no postconditions for boolean queries)

---

## SIMPLE_STRING_CONVERSIONS [G]

### Identity
- **Role**: FACADE
- **Domain Concept**: String Conversions
- **Lines**: 79

### Purpose
Utilities for converting between collections and string representations. Stateless utility class.

### Queries
| Feature | Returns | Preconditions | Postconditions |
|---------|---------|---------------|----------------|
| `joined (a_items, a_separator)` | STRING_32 | items_exists, separator_exists | result_exists |
| `joined_with_format (a_items, a_separator, a_formatter)` | STRING_32 | items_exists, separator_exists, formatter_exists | result_exists |
| `split_to_list (a_string, a_separator, a_converter)` | ARRAYED_LIST [G] | string_exists, converter_exists | result_exists |

### Invariants
None (stateless)

### Contract Coverage: MODERATE (preconditions good, postconditions minimal)

---

## SIMPLE_CURSOR_GUARD

### Identity
- **Role**: HELPER
- **Domain Concept**: Cursor Guard
- **Lines**: 50

### Purpose
RAII-style cursor position preservation. Saves cursor on creation, restores on demand.

### Creation
| Procedure | Preconditions | Postconditions |
|-----------|---------------|----------------|
| `make (a_cursored: LINEAR [ANY])` | cursored_exists | target_set |

### Commands
| Feature | Purpose |
|---------|---------|
| `restore` | Restore saved cursor position if valid |

### Queries
| Feature | Returns | Purpose |
|---------|---------|---------|
| `saved_cursor` | detachable CURSOR | The saved cursor |

### Invariants
```eiffel
target_exists: target /= Void
```

### Contract Coverage: MODERATE (cursor validity check in restore)

---

## Summary

| Class | Role | Lines | Invariants | Coverage |
|-------|------|-------|------------|----------|
| SIMPLE_QUERY_CONDITION | ABSTRACT | 31 | N/A | N/A |
| SIMPLE_PREDICATE_CONDITION | ENGINE | 71 | YES | STRONG |
| SIMPLE_AND_CONDITION | ENGINE | 78 | YES | STRONG |
| SIMPLE_OR_CONDITION | ENGINE | 78 | YES | STRONG |
| SIMPLE_NOT_CONDITION | ENGINE | 71 | YES | STRONG |
| SIMPLE_LIST_QUERY | FACADE | 128 | YES | STRONG |
| SIMPLE_LIST_EXTENSIONS | FACADE | 163 | YES | STRONG |
| SIMPLE_SLICE | FACADE | 170 | YES | STRONG |
| SIMPLE_SLICE_CURSOR | HELPER | 69 | YES | STRONG |
| SIMPLE_SET_OPERATIONS | FACADE | 110 | NO | MODERATE |
| SIMPLE_STRING_CONVERSIONS | FACADE | 79 | NO | MODERATE |
| SIMPLE_CURSOR_GUARD | HELPER | 50 | YES | MODERATE |

**Total Classes**: 12
**With Invariants**: 10 (83%)
**Strong Contract Coverage**: 9 (75%)
