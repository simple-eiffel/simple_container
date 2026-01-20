# Changelog

All notable changes to simple_container will be documented in this file.

## [1.0.0] - 2026-01-20

### Added
- Initial release
- SIMPLE_QUERY_CONDITION [G] - Abstract composable boolean condition
- SIMPLE_PREDICATE_CONDITION [G] - Condition from PREDICATE agent
- SIMPLE_AND_CONDITION [G] - Conjunction of conditions
- SIMPLE_OR_CONDITION [G] - Disjunction of conditions
- SIMPLE_NOT_CONDITION [G] - Negation of condition
- SIMPLE_LIST_QUERY [G] - Cursor-safe query operations
- SIMPLE_LIST_EXTENSIONS [G] - List extension operations
- SIMPLE_SLICE [G] - Lazy slice view
- SIMPLE_SLICE_CURSOR [G] - Cursor for slice iteration
- SIMPLE_SET_OPERATIONS [G] - Set operations (union, intersection, etc.)
- SIMPLE_STRING_CONVERSIONS [G] - String conversion utilities
- SIMPLE_CURSOR_GUARD - RAII-style cursor preservation

### Features
- Composable query conditions with boolean algebra (and, or, not)
- Cursor-safe list operations via across iteration
- Lazy slice evaluation without copying
- Set operations on any ITERABLE
- String join/split utilities
- Full Design by Contract coverage
- Void-safe implementation
- SCOOP-compatible design
- 29 unit tests + 7 adversarial edge case tests
