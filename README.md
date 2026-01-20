<p align="center">
  <img src="docs/images/logo.png" alt="simple_container logo" width="200">
</p>

<h1 align="center">simple_container</h1>

<p align="center">
  <a href="https://simple-eiffel.github.io/simple_container/">Documentation</a> •
  <a href="https://github.com/simple-eiffel/simple_container">GitHub</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT">
  <img src="https://img.shields.io/badge/Eiffel-25.02-purple.svg" alt="Eiffel 25.02">
  <img src="https://img.shields.io/badge/DBC-Contracts-green.svg" alt="Design by Contract">
</p>

**Functional-style collection operations with composable query conditions** — Part of the [Simple Eiffel](https://github.com/simple-eiffel) ecosystem.

## Status

✅ **Production Ready** — v1.0.0
- 12 classes
- **129 tests total**
  - 100 internal (DBC contract assertions)
  - 29 external (unit tests)

## Overview

simple_container provides functional-style operations for Eiffel collections without cursor manipulation headaches. Instead of manually managing cursors with `start`, `forth`, and `after`, you use composable query conditions and declarative operations like `filtered`, `take`, `drop`, and `partition`.

The library introduces a boolean algebra of query conditions where you can combine predicates using `and`, `or`, and `not` operators. These conditions work seamlessly with list queries, extensions, and other collection operations.

Key features include lazy slicing (views into arrays/lists without copying), set operations (union, intersection, difference), and string conversion utilities. All operations are cursor-safe, void-safe, and SCOOP-compatible.

## Quick Start

```eiffel
local
    l_list: ARRAYED_LIST [INTEGER]
    l_query: SIMPLE_LIST_QUERY [INTEGER]
    l_cond: SIMPLE_PREDICATE_CONDITION [INTEGER]
    l_result: ARRAYED_LIST [INTEGER]
do
    -- Create a list and query wrapper
    create l_list.make_from_array (<<1, 2, 3, 4, 5, 6, 7, 8, 9, 10>>)
    create l_query.make (l_list)

    -- Filter items > 5
    create l_cond.make (agent (i: INTEGER): BOOLEAN do Result := i > 5 end)
    l_result := l_query.filtered (l_cond)
    -- l_result contains: 6, 7, 8, 9, 10
end
```

## API Reference

### SIMPLE_QUERY_CONDITION [G]

Base class for composable boolean conditions.

| Feature | Description |
|---------|-------------|
| `satisfied_by (a_item)` | Check if item satisfies condition |
| `conjuncted alias "and"` | Combine with AND |
| `disjuncted alias "or"` | Combine with OR |
| `negated alias "not"` | Negate condition |

### SIMPLE_PREDICATE_CONDITION [G]

Condition from a PREDICATE agent.

| Feature | Description |
|---------|-------------|
| `make (a_predicate)` | Create from predicate agent |

### SIMPLE_LIST_QUERY [G]

Query operations on lists (cursor-safe).

| Feature | Description |
|---------|-------------|
| `make (a_list)` | Create query wrapper |
| `filtered (a_condition)` | Items satisfying condition |
| `first_satisfying (a_condition)` | First matching item or Void |
| `all_satisfy (a_condition)` | Do all items satisfy? |
| `any_satisfies (a_condition)` | Does any item satisfy? |
| `count_satisfying (a_condition)` | Count of matching items |
| `mapped (a_function)` | Apply function to each item |
| `folded (a_initial, a_combiner)` | Reduce to single value |

### SIMPLE_LIST_EXTENSIONS [G]

Extension operations for lists.

| Feature | Description |
|---------|-------------|
| `make (a_list)` | Create extensions wrapper |
| `partition (a_condition)` | Split into satisfying/not satisfying |
| `group_by (a_key_function)` | Group by key |
| `reversed` | Items in reverse order |
| `take (n)` | First n items |
| `drop (n)` | All except first n items |
| `take_while (a_condition)` | Leading items satisfying condition |
| `drop_while (a_condition)` | Items after leading sequence |

### SIMPLE_SLICE [G]

Lazy slice view into arrays/lists.

| Feature | Description |
|---------|-------------|
| `make (a_source, a_start, a_end)` | Create slice from range |
| `make_from_end (a_source, a_offset, a_count)` | Create slice from end |
| `item alias "[]" (i)` | Item at position |
| `first` / `last` | First/last items |
| `count` / `is_empty` | Size queries |
| `to_array` / `to_list` | Convert to concrete container |
| `sub_slice (a_start, a_end)` | Sub-slice |

### SIMPLE_SET_OPERATIONS [G -> HASHABLE]

Set operations on collections.

| Feature | Description |
|---------|-------------|
| `union (a_first, a_second)` | All items in either |
| `intersection (a_first, a_second)` | Items in both |
| `difference (a_first, a_second)` | Items in first but not second |
| `symmetric_difference` | Items in exactly one |
| `is_subset (a_candidate, a_superset)` | Subset check |
| `is_disjoint (a_first, a_second)` | No common items? |

### SIMPLE_STRING_CONVERSIONS [G]

Convert containers to/from strings.

| Feature | Description |
|---------|-------------|
| `joined (a_items, a_separator)` | Join items with separator |
| `joined_with_format (a_items, a_sep, a_formatter)` | Join with custom formatting |
| `split_to_list (a_string, a_sep, a_converter)` | Parse string to list |

## Features

- ✅ Composable query conditions with boolean algebra
- ✅ Cursor-safe list operations via across iteration
- ✅ Lazy slice evaluation (no copying)
- ✅ Set operations (union, intersection, difference)
- ✅ String conversion utilities
- ✅ Design by Contract throughout
- ✅ Void-safe
- ✅ SCOOP-compatible

## Installation

### Using as ECF Dependency

Add to your `.ecf` file:

```xml
<library name="simple_container" location="$SIMPLE_LIBS/simple_container/simple_container.ecf"/>
```

### Environment Setup

Set the `SIMPLE_LIBS` environment variable:
```bash
export SIMPLE_LIBS=/path/to/simple/libraries
```

## Dependencies

| Library | Purpose |
|---------|---------|
| ISE Base | Standard Eiffel library (ARRAYED_LIST, HASH_TABLE, etc.) |

## License

MIT License - see [LICENSE](LICENSE) file.

---

Part of the [Simple Eiffel](https://github.com/simple-eiffel) ecosystem.
