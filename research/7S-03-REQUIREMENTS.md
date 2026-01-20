# 7S-03: Requirements - simple_container Improvements

## Date: 2026-01-20

---

## Requirements Summary

| Type | MUST | SHOULD | COULD | Total |
|------|------|--------|-------|-------|
| Functional | 2 | 4 | 4 | 10 |
| Non-Functional | 4 | - | - | 4 |

---

## Functional Requirements

### MUST Have (Core)

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-001 | min_by/max_by operations | Return first minimum/maximum element by selector, or Void if empty |
| FR-002 | index_of_first/index_of_last | Return index of first/last matching element, or 0 if not found |

### SHOULD Have (Important)

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-003 | sorted_by operation | Return new list sorted by selector (requires G -> COMPARABLE for key) |
| FR-004 | distinct operation | Return new list with duplicates removed (requires G -> HASHABLE) |
| FR-005 | zip operation | Combine two lists element-by-element into tuple list |
| FR-006 | flatten operation | Convert nested list to flat list |

### COULD Have (Nice to Have)

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-007 | chunked operation | Split list into fixed-size sublists |
| FR-008 | windowed operation | Create sliding window sublists |
| FR-009 | indexed_filter | Filter with access to index |
| FR-010 | indexed_map | Map with access to index |

---

## Feature Specifications

### FR-001: min_by / max_by

```eiffel
min_by (a_selector: FUNCTION [G, COMPARABLE]): detachable G
    -- Element with minimum selector value, or Void if empty
  require
    selector_exists: a_selector /= Void
  -- Returns Void if target is empty (detachable result)

max_by (a_selector: FUNCTION [G, COMPARABLE]): detachable G
    -- Element with maximum selector value, or Void if empty
  require
    selector_exists: a_selector /= Void
```

**Usage Example**:
```eiffel
-- Find person with lowest age
l_youngest := l_ext.min_by (agent (p: PERSON): INTEGER do Result := p.age end)

-- Find longest string
l_longest := l_ext.max_by (agent (s: STRING): INTEGER do Result := s.count end)
```

### FR-002: index_of_first / index_of_last

```eiffel
index_of_first (a_condition: SIMPLE_QUERY_CONDITION [G]): INTEGER
    -- Index of first matching element (1-based), or 0 if none
  require
    condition_exists: a_condition /= Void
  ensure
    valid_or_zero: Result >= 0 and Result <= target.count

index_of_last (a_condition: SIMPLE_QUERY_CONDITION [G]): INTEGER
    -- Index of last matching element (1-based), or 0 if none
```

### FR-003: sorted_by (NEW CLASS)

```eiffel
class SIMPLE_SORTABLE_LIST_EXTENSIONS [G]

sorted_by (a_key: FUNCTION [G, COMPARABLE]): ARRAYED_LIST [G]
    -- Elements sorted by key selector (ascending)
  require
    key_function_exists: a_key /= Void
  ensure
    result_exists: Result /= Void
    same_count: Result.count = target.count

sorted_by_descending (a_key: FUNCTION [G, COMPARABLE]): ARRAYED_LIST [G]
    -- Elements sorted by key selector (descending)
```

### FR-004: distinct (NEW CLASS)

```eiffel
class SIMPLE_HASHABLE_LIST_EXTENSIONS [G -> HASHABLE]

distinct: ARRAYED_LIST [G]
    -- Elements with duplicates removed (preserves first occurrence order)
  ensure
    result_exists: Result /= Void
    no_larger: Result.count <= target.count

distinct_by (a_key: FUNCTION [G, HASHABLE]): ARRAYED_LIST [G]
    -- Elements with duplicates by key removed
```

### FR-005: zip

```eiffel
zip [H] (a_other: LIST [H]): ARRAYED_LIST [TUPLE [first: G; second: H]]
    -- Combine with other list element-by-element
    -- Result length is minimum of both list lengths
  require
    other_exists: a_other /= Void
  ensure
    result_exists: Result /= Void
    correct_count: Result.count = target.count.min (a_other.count)
```

### FR-006: flatten

```eiffel
class SIMPLE_NESTED_LIST_EXTENSIONS [G]

flatten: ARRAYED_LIST [G]
    -- Flatten nested list (LIST [LIST [G]] -> LIST [G])
  ensure
    result_exists: Result /= Void
```

### FR-007/FR-008: chunked / windowed

```eiffel
chunked (a_size: INTEGER): ARRAYED_LIST [ARRAYED_LIST [G]]
    -- Split into sublists of given size (last may be smaller)
  require
    positive_size: a_size > 0
  ensure
    result_exists: Result /= Void

windowed (a_size: INTEGER): ARRAYED_LIST [ARRAYED_LIST [G]]
    -- Sliding window sublists of given size
  require
    positive_size: a_size > 0
```

---

## Non-Functional Requirements

| ID | Category | Requirement | Target |
|----|----------|-------------|--------|
| NFR-001 | Compatibility | All new features void-safe | 100% |
| NFR-002 | Compatibility | All new features SCOOP-compatible | 100% |
| NFR-003 | Maintainability | Full DBC coverage | Pre+Post on all features |
| NFR-004 | Testability | Comprehensive tests | At least 2 tests per feature |

---

## Constraints

| ID | Constraint | Impact |
|----|------------|--------|
| C-001 | sorted requires COMPARABLE key | New class with constraint |
| C-002 | distinct requires HASHABLE | New class with constraint |
| C-003 | No breaking changes | Add features, don't modify existing |
| C-004 | Follow existing patterns | Match API style |

---

## Implementation Strategy

### Phase 1: Add to SIMPLE_LIST_EXTENSIONS
- min_by, max_by
- index_of_first, index_of_last
- zip
- chunked, windowed

### Phase 2: Create SIMPLE_SORTABLE_LIST_EXTENSIONS [G -> COMPARABLE constraint on key]
- sorted_by, sorted_by_descending

### Phase 3: Create SIMPLE_HASHABLE_LIST_EXTENSIONS [G -> HASHABLE]
- distinct, distinct_by

### Phase 4: Create SIMPLE_NESTED_LIST_EXTENSIONS (for LIST [LIST [G]])
- flatten
