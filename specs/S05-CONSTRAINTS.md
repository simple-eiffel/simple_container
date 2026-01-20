# S05: System Constraints - simple_container

## Date: 2026-01-20

---

## Invariant Collection

### SIMPLE_PREDICATE_CONDITION
```eiffel
predicate_exists: predicate /= Void
```
- **Meaning**: The underlying predicate agent must always exist
- **Protects**: NullPointerException when evaluating condition

### SIMPLE_AND_CONDITION / SIMPLE_OR_CONDITION
```eiffel
left_exists: left /= Void
right_exists: right /= Void
```
- **Meaning**: Both operands must always exist
- **Protects**: NullPointerException when evaluating compound condition

### SIMPLE_NOT_CONDITION
```eiffel
operand_exists: operand /= Void
```
- **Meaning**: The operand to negate must always exist
- **Protects**: NullPointerException when evaluating negation

### SIMPLE_LIST_QUERY / SIMPLE_LIST_EXTENSIONS
```eiffel
target_exists: target /= Void
```
- **Meaning**: The wrapped list must always exist
- **Protects**: NullPointerException in all list operations

### SIMPLE_SLICE
```eiffel
source_exists: source /= Void
count_consistent: count = (end_index - start_index + 1).max (0)
```
- **Meaning**: Source must exist; count must match actual range
- **Protects**: Invalid memory access; inconsistent count reports

### SIMPLE_SLICE_CURSOR
```eiffel
slice_exists: slice /= Void
position_positive: position >= 1
```
- **Meaning**: Cursor must reference valid slice; position is 1-based
- **Protects**: Cursor operations on invalid references; off-by-one errors

### SIMPLE_CURSOR_GUARD
```eiffel
target_exists: target /= Void
```
- **Meaning**: The guarded container must exist
- **Protects**: Attempting to restore cursor on void reference

---

## Constraint Categorization

### Category: Data Integrity

| Constraint | Where Enforced |
|------------|----------------|
| Predicate agents non-void | SIMPLE_PREDICATE_CONDITION invariant |
| Condition operands non-void | SIMPLE_AND/OR/NOT_CONDITION invariants |
| Wrapper targets non-void | SIMPLE_LIST_QUERY/EXTENSIONS invariants |
| Slice sources non-void | SIMPLE_SLICE invariant |

### Category: State Validity

| Constraint | Where Enforced |
|------------|----------------|
| Slice count consistent with bounds | SIMPLE_SLICE invariant |
| Cursor position >= 1 | SIMPLE_SLICE_CURSOR invariant |
| Slice indices within source bounds | SIMPLE_SLICE make preconditions |

### Category: Relationship Consistency

| Constraint | Where Enforced |
|------------|----------------|
| Partition total = target total | SIMPLE_LIST_EXTENSIONS.partition postcondition |
| Filtered count <= target count | SIMPLE_LIST_QUERY.filtered postcondition |
| Mapped count = target count | SIMPLE_LIST_QUERY.mapped postcondition |
| Reversed count = target count | SIMPLE_LIST_EXTENSIONS.reversed postcondition |

### Category: Business Rules

| Constraint | Where Enforced |
|------------|----------------|
| take/drop n must be non-negative | Preconditions |
| Slice range must be valid | make preconditions |
| Set operations require HASHABLE | Generic constraint G -> HASHABLE |

---

## Cross-Class Constraints

### Rule: Condition operands must be non-void
**Enforced in**:
- SIMPLE_PREDICATE_CONDITION.conjuncted, disjuncted (precondition)
- SIMPLE_AND_CONDITION.make (precondition)
- SIMPLE_OR_CONDITION.make (precondition)
- SIMPLE_NOT_CONDITION.make (precondition)

**Meaning**: All condition composition operations require non-void operands to prevent runtime failures.

### Rule: Result existence guarantee
**Enforced in**: All composition features have `ensure then result_exists: Result /= Void`

**Meaning**: Composition always produces valid, non-void results.

### Rule: Collection bounds preservation
**Enforced in**:
- SIMPLE_LIST_QUERY.filtered (postcondition: bounded)
- SIMPLE_LIST_QUERY.count_satisfying (postcondition: bounded)
- SIMPLE_LIST_EXTENSIONS.take (postcondition: bounded_count)
- SIMPLE_LIST_EXTENSIONS.drop (postcondition: correct_count)

**Meaning**: Derived collections never exceed source size.

---

## Implicit Constraints (Assumptions)

### 1. PREDICATE evaluation is side-effect free
**Evidence**: `satisfied_by` is documented as query, assumes predicate doesn't modify state
**Should be**: Documented in note clause
**Risk**: Side-effecting predicates could cause unexpected behavior during iteration

### 2. Source container stability during slice operations
**Evidence**: SIMPLE_SLICE stores reference to source, assumes source doesn't change
**Should be**: Documented warning that modifying source invalidates slice
**Risk**: IndexOutOfBounds or stale data if source modified

### 3. Hash function stability for set operations
**Evidence**: Set operations use ARRAYED_SET which depends on hash values
**Should be**: Documented that hash values must be stable
**Risk**: Items may not be found if hash changes after insertion

### 4. Iterator cursor safety via `across`
**Evidence**: All list operations use `across` instead of manual cursor manipulation
**Should be**: Design decision - cursor-safe by design
**Risk**: None - this is correctly implemented

---

## Void Safety Constraints

### Detachable Attributes

| Class | Attribute | When Void Allowed |
|-------|-----------|-------------------|
| SIMPLE_CURSOR_GUARD | saved_cursor | When target is not CURSOR_STRUCTURE |
| SIMPLE_LIST_QUERY | first_satisfying result | When no item satisfies condition |
| SIMPLE_LIST_QUERY | folded result | When initial was Void or combiner returns Void |

### Void-Safe Patterns Used

1. **attached checks**: Used in SIMPLE_CURSOR_GUARD.restore
2. **across iteration**: Inherently void-safe
3. **local flags**: Used instead of `Result /= Void` for expanded types (first_satisfying)

---

## Temporal Constraints

### Rule: Create before use
**Before**: Call to `make` or `make_from_end`
**After**: All other operations
**Enforced by**: Eiffel creation system - cannot call features on uncreated objects

### Rule: Iterate only when not modified
**Before**: Iteration begins
**After**: Iteration completes
**Enforced by**: Convention - no contract enforcement
**Risk**: Concurrent modification during iteration (SCOOP handles this)

---

## Constraint Completeness

### Missing Constraints (Should Add)

1. **SIMPLE_SLICE**: Should have postcondition that sub_slice produces valid slice within parent bounds

2. **SIMPLE_SET_OPERATIONS**: Boolean result queries (is_subset, is_disjoint) lack postconditions

3. **SIMPLE_STRING_CONVERSIONS.split_to_list**: No postcondition guaranteeing result reflects all parts

4. **SIMPLE_LIST_QUERY.mapped**: Could have postcondition that Result preserves item order

5. **SIMPLE_LIST_EXTENSIONS.group_by**: No postcondition about total items preserved across groups

### Well-Specified Constraints

- All invariants properly protect object validity
- All factory methods ensure result existence
- Partition preserves total (strong mathematical property)
- Filtered/count bounded by target size

---

## Summary

| Constraint Type | Count | Coverage |
|-----------------|-------|----------|
| Class invariants | 11 | 10/12 classes (83%) |
| Preconditions | 31 | All public features |
| Postconditions | 24 | Most features |
| Cross-class rules | 3 | Composition, bounds, existence |
| Implicit (undocumented) | 4 | Should formalize |
| Missing (recommended) | 5 | Lower priority |
