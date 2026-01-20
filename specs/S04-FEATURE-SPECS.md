# S04: Feature Specifications - simple_container

## Date: 2026-01-20

---

## Priority Features (Facade Entry Points)

### 1. SIMPLE_LIST_QUERY.filtered

```eiffel
filtered (a_condition: SIMPLE_QUERY_CONDITION [G]): ARRAYED_LIST [G]
```

**Purpose**: Return all items from the wrapped list that satisfy the given condition.

**Algorithm**:
1. Create empty result list (pre-sized to half of target)
2. Iterate target using `across` (cursor-safe)
3. For each item, check if condition is satisfied
4. If satisfied, extend result with item
5. Return result

**Code Paths**:
- Path A: Empty target → returns empty list
- Path B: No items satisfy → returns empty list
- Path C: Some items satisfy → returns matching items
- Path D: All items satisfy → returns copy of all items

**Contracts**:
```eiffel
require
  condition_exists: a_condition /= Void
ensure
  result_exists: Result /= Void
  bounded: Result.count <= target.count
```

**Edge Cases**:
- Empty list: Returns empty list (tested)
- All match: Returns list with same count as target
- None match: Returns empty list

**Test Coverage**: test_filtered (LIB_TESTS:76-88)

---

### 2. SIMPLE_LIST_QUERY.first_satisfying

```eiffel
first_satisfying (a_condition: SIMPLE_QUERY_CONDITION [G]): detachable G
```

**Purpose**: Return the first item satisfying the condition, or Void if none found.

**Algorithm**:
1. Set found flag to False
2. Iterate target using `across` until found
3. For each item, check if condition satisfied
4. If satisfied, set Result and found flag
5. Return Result (may be Void)

**Code Paths**:
- Path A: Empty target → returns Void
- Path B: First item matches → returns first item
- Path C: Later item matches → returns that item
- Path D: No items match → returns Void

**Contracts**:
```eiffel
require
  condition_exists: a_condition /= Void
-- No postcondition (detachable result)
```

**Important Note**: For expanded types (INTEGER, REAL, etc.), cannot distinguish between "not found" and "found default value". Use reference types for nullable results.

**Edge Cases**:
- Empty list: Returns Void (tested)
- Single element matching: Returns that element (tested)
- No match in non-empty: Returns Void

**Test Coverage**: test_first_satisfying (LIB_TESTS:90-105), test_empty_list_operations (ADVERSARIAL:29-32)

---

### 3. SIMPLE_LIST_EXTENSIONS.partition

```eiffel
partition (a_condition: SIMPLE_QUERY_CONDITION [G]): TUPLE [satisfying: ARRAYED_LIST [G]; not_satisfying: ARRAYED_LIST [G]]
```

**Purpose**: Split list into two lists: items satisfying and not satisfying the condition.

**Algorithm**:
1. Create two empty lists (pre-sized to half of target each)
2. Iterate target using `across`
3. For each item, check if condition satisfied
4. If satisfied, add to satisfying list; else add to not_satisfying
5. Return tuple of both lists

**Contracts**:
```eiffel
require
  condition_exists: a_condition /= Void
ensure
  result_exists: Result /= Void
  total_preserved: Result.satisfying.count + Result.not_satisfying.count = target.count
```

**Invariant Guarantee**: No items lost - total always equals target count.

**Edge Cases**:
- Empty list: Both result lists empty (tested)
- All match: satisfying has all, not_satisfying empty
- None match: satisfying empty, not_satisfying has all

**Test Coverage**: test_partition (LIB_TESTS:278-292), test_empty_list_operations (ADVERSARIAL:44-45)

---

### 4. SIMPLE_LIST_EXTENSIONS.take / drop

```eiffel
take (n: INTEGER): ARRAYED_LIST [G]
drop (n: INTEGER): ARRAYED_LIST [G]
```

**Purpose**:
- `take`: Return first n items (or all if fewer than n)
- `drop`: Return all items except first n (or empty if n >= count)

**Algorithm (take)**:
1. Calculate actual count as min(n, target.count)
2. Create result list with that capacity
3. Copy first l_count items using index access
4. Return result

**Algorithm (drop)**:
1. Calculate start index as min(n + 1, target.count + 1)
2. Create result list with remaining capacity
3. Copy items from start to end using index access
4. Return result

**Contracts**:
```eiffel
-- take
require
  non_negative: n >= 0
ensure
  result_exists: Result /= Void
  bounded_count: Result.count <= n and Result.count <= target.count

-- drop
require
  non_negative: n >= 0
ensure
  result_exists: Result /= Void
  correct_count: Result.count = (target.count - n).max (0)
```

**Edge Cases (tested in ADVERSARIAL:197-223)**:
- take(0): Empty list
- drop(0): All items
- take(exact): All items
- drop(exact): Empty list
- take(more): All items (capped)
- drop(more): Empty list

---

### 5. SIMPLE_SLICE.make / item

```eiffel
make (a_source: READABLE_INDEXABLE [G]; a_start, a_end: INTEGER)
item alias "[]" (i: INTEGER): G
```

**Purpose**: Create lazy view into source array/list without copying. Access items via 1-based index within slice.

**Algorithm (item)**:
1. Translate slice index i to source index: start_index + i - 1
2. Return source[translated_index]

**Contracts**:
```eiffel
-- make
require
  source_exists: a_source /= Void
  valid_start: a_start >= a_source.lower
  valid_end: a_end <= a_source.upper
  valid_range: a_start <= a_end + 1  -- allows empty slice
ensure
  source_set: source = a_source
  start_set: start_index = a_start
  end_set: end_index = a_end

-- item
require
  valid_index: valid_index (i)  -- i >= 1 and i <= count
```

**Edge Cases (tested in ADVERSARIAL:88-108)**:
- Full array slice: Works normally
- Single element slice: count = 1
- Empty slice (start = end + 1): count = 0, is_empty = True

---

### 6. SIMPLE_SET_OPERATIONS.union / intersection / difference

```eiffel
union (a_first, a_second: ITERABLE [G]): ARRAYED_SET [G]
intersection (a_first, a_second: ITERABLE [G]): ARRAYED_SET [G]
difference (a_first, a_second: ITERABLE [G]): ARRAYED_SET [G]
```

**Purpose**: Mathematical set operations on collections.

**Algorithm (intersection)**:
1. Build set from second collection
2. Create empty result set
3. Iterate first collection
4. For each item, if in second set, add to result
5. Return result (automatically handles duplicates)

**Contracts**:
```eiffel
require
  first_exists: a_first /= Void
  second_exists: a_second /= Void
ensure
  result_exists: Result /= Void
```

**Type Constraint**: G -> HASHABLE (required for ARRAYED_SET)

**Edge Cases (tested in ADVERSARIAL:110-145)**:
- Empty first: Result based on operation semantics
- Empty second: Result based on operation semantics
- Disjoint sets: Intersection empty
- Identical sets: Union = Intersection = either set

---

## Condition Composition Features

### 7. Boolean Algebra (and/or/not)

```eiffel
conjuncted alias "and" (a_other: SIMPLE_QUERY_CONDITION [G]): SIMPLE_AND_CONDITION [G]
disjuncted alias "or" (a_other: SIMPLE_QUERY_CONDITION [G]): SIMPLE_OR_CONDITION [G]
negated alias "not": SIMPLE_NOT_CONDITION [G]
```

**Purpose**: Enable composition of conditions using natural Eiffel operator syntax.

**Usage Example**:
```eiffel
l_complex := (l_gt5 and l_lt10) or (not l_even)
```

**Contracts**:
```eiffel
-- and/or
require else
  other_exists: a_other /= Void
ensure then
  result_exists: Result /= Void

-- not (unary)
ensure then
  result_exists: Result /= Void
```

**Composition Depth**: Unlimited - can nest arbitrarily deep. Tested with 3-level composition in ADVERSARIAL:167-195.

---

## Summary: Feature Test Matrix

| Feature | LIB_TESTS | ADVERSARIAL | Edge Cases |
|---------|-----------|-------------|------------|
| filtered | YES | YES (empty) | Empty, all, none |
| first_satisfying | YES | YES (empty, single) | Empty, not found |
| all_satisfy | YES | YES (vacuous) | Empty = True |
| any_satisfies | YES | YES (empty) | Empty = False |
| count_satisfying | YES | YES (empty) | Empty = 0 |
| partition | YES | YES (empty) | Total preserved |
| take/drop | YES | YES (boundaries) | 0, exact, more |
| slice make/item | YES | YES (boundaries) | Full, single, empty |
| set operations | YES | YES (empty) | Empty collections |
| string join | YES | YES (empty, single) | No separator for single |
| condition composition | YES | YES (complex) | Deep nesting |
