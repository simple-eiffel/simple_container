# 7S-06: Risks - simple_container Improvements

## Date: 2026-01-20

---

## Risk Summary

| ID | Risk | Likelihood | Impact | Priority |
|----|------|------------|--------|----------|
| R-01 | Type constraint complexity | MEDIUM | MEDIUM | MEDIUM |
| R-02 | sorted_by performance | LOW | LOW | LOW |
| R-03 | API consistency | LOW | MEDIUM | LOW |
| R-04 | Breaking existing code | LOW | HIGH | MEDIUM |

**Overall Risk Level**: LOW

---

## Risk Analysis

### R-01: Type Constraint Complexity

**Description**: Adding features like distinct (requires HASHABLE) and sorted_by (requires COMPARABLE on key) means users must use different classes based on their type constraints.

**Likelihood**: MEDIUM - Users may be confused about which class to use

**Impact**: MEDIUM - Usability friction

**Mitigation**:
1. Clear documentation explaining which class to use when
2. Consistent naming pattern (SIMPLE_HASHABLE_LIST_EXTENSIONS, etc.)
3. Compile-time errors guide users to correct class

**Residual Risk**: LOW - Eiffel type system provides clear error messages

---

### R-02: sorted_by Performance

**Description**: Sorting requires O(n log n) time and creates a full copy of the list.

**Likelihood**: LOW - This is expected behavior for sorting

**Impact**: LOW - Standard algorithmic complexity

**Mitigation**:
1. Document time complexity
2. Use QUICK_SORTER from ISE (optimized implementation)
3. Note: For very large lists, consider alternatives

**Residual Risk**: VERY LOW - Expected behavior, documented

---

### R-03: API Consistency

**Description**: New features must match existing API patterns to avoid confusion.

**Likelihood**: LOW - We're following established patterns

**Impact**: MEDIUM - Inconsistent API hurts usability

**Mitigation**:
1. Follow existing naming conventions exactly
2. Match existing parameter patterns (condition objects, agents)
3. Code review before merge

**Residual Risk**: VERY LOW

---

### R-04: Breaking Existing Code

**Description**: Changes could potentially break existing code using the library.

**Likelihood**: LOW - We're only adding features, not modifying

**Impact**: HIGH - Would break user code

**Mitigation**:
1. Add new features only, don't modify existing
2. New classes for constrained features
3. All existing tests must pass
4. Version bump clearly indicates additions

**Residual Risk**: VERY LOW - Adding only, no modifications

---

## Edge Case Risks

### Empty Collection Handling

**Risk**: Operations on empty collections could behave unexpectedly

**Mitigation**:
- min_by/max_by return Void on empty (documented)
- index_of_first/index_of_last return 0 on empty (Eiffel convention)
- chunked/windowed return empty list on empty
- All edge cases tested

### Very Large Collections

**Risk**: Memory issues with operations that create copies

**Mitigation**:
- Document that operations create copies
- Recommend SIMPLE_SLICE for large data views
- No mitigation needed beyond documentation (expected behavior)

---

## Testing Risks

### Risk: Insufficient Test Coverage

**Mitigation**:
- At least 2 tests per new feature
- Edge case tests (empty, single element)
- Boundary tests (large values)
- Integration with existing tests

### Test Plan for New Features

| Feature | Normal Test | Empty Test | Edge Test |
|---------|-------------|------------|-----------|
| min_by | Find min in list | Return Void | Single element |
| max_by | Find max in list | Return Void | Single element |
| index_of_first | Find matching | Return 0 | Match at end |
| index_of_last | Find last match | Return 0 | Match at start |
| sorted_by | Sort numbers | Empty list | Already sorted |
| distinct | Remove dupes | Empty list | All same |
| zip | Combine lists | Either empty | Unequal lengths |
| chunked | Split into groups | Empty | Exact divisor |
| windowed | Create windows | Empty | Size > count |

---

## Contingency Plans

### If Type Constraints Cause Confusion
- Add factory methods to create appropriate wrapper
- Improve documentation with examples
- Add FAQ section

### If Performance Issues Arise
- Profile to identify bottleneck
- Consider caching strategies
- Document performance characteristics

---

## Risk Matrix

```
        IMPACT
        LOW    MEDIUM    HIGH
   ┌──────────────────────────┐
L  │         │         │      │
I  │         │         │  R-04│
K  │         │         │      │
E  ├──────────────────────────┤
L  │         │  R-01   │      │
I  │         │         │      │
H  ├──────────────────────────┤
O  │  R-02   │  R-03   │      │
O  │         │         │      │
D  └──────────────────────────┘
```

All risks are in low-likelihood or low-impact zones. **PROCEED** is recommended.
