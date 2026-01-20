# 7S-07: Recommendation - simple_container Improvements

## Date: 2026-01-20

---

## Executive Summary

**Recommendation**: **PROCEED**

simple_container should be enhanced with additional functional programming operations based on research of Java Streams, C# LINQ, and Kotlin collections. The highest-value additions are:

1. **min_by / max_by** - Find extrema by selector
2. **index_of_first / index_of_last** - Find index of matching element
3. **sorted_by** - Sort by key selector
4. **distinct** - Remove duplicates
5. **zip** - Combine parallel lists
6. **chunked / windowed** - Kotlin-inspired batch operations

---

## Key Findings

1. **Gap Analysis Confirmed**: All identified gaps (sorting, distinct, min/max, etc.) are standard operations in Java, C#, and Kotlin.

2. **Kotlin Leadership**: Kotlin has the most comprehensive collection API. Its `chunked()` and `windowed()` operations are not in Java Streams or C# LINQ.

3. **Type Constraints Manageable**: Features requiring type constraints (sorted needs COMPARABLE, distinct needs HASHABLE) will be in separate classes.

4. **Low Implementation Risk**: All features are well-understood patterns. No novel algorithms needed.

---

## Key Risks

| Risk | Mitigation |
|------|------------|
| Type constraint complexity | Clear documentation, separate classes |
| Breaking existing code | Add-only approach, no modifications |

---

## Go/No-Go Assessment

| Factor | Weight | Score | Weighted |
|--------|--------|-------|----------|
| Problem value | 3 | 4 | 12 |
| Solution viability | 3 | 5 | 15 |
| Competitive advantage | 2 | 3 | 6 |
| Risk level (inverted) | 3 | 4 | 12 |
| Resource availability | 2 | 5 | 10 |
| Strategic fit | 2 | 5 | 10 |
| **Total** | 15 | | **65/75** |

**Score Interpretation**: 65/75 = **Strong GO**

---

## Recommendation Details

### What We Should Do

**PROCEED** with implementing the following features in priority order:

**Priority 1 (MUST - Add to SIMPLE_LIST_EXTENSIONS)**:
- `min_by`, `max_by` - Find element with min/max by selector
- `index_of_first`, `index_of_last` - Find index of matching element

**Priority 2 (SHOULD - New classes)**:
- `sorted_by`, `sorted_by_descending` - In SIMPLE_SORTABLE_LIST_EXTENSIONS
- `distinct`, `distinct_by` - In SIMPLE_HASHABLE_LIST_EXTENSIONS [G -> HASHABLE]

**Priority 3 (COULD - Add to SIMPLE_LIST_EXTENSIONS)**:
- `zip` - Combine two lists
- `chunked`, `windowed` - Batch operations

### Why

1. **User Value**: These are commonly needed operations
2. **Low Risk**: Well-understood implementations
3. **Ecosystem Consistency**: Matches simple_* quality standards
4. **Competitive**: Brings Eiffel up to par with modern languages

### Conditions

1. All existing tests must continue to pass
2. Each new feature needs at least 2 tests
3. Full DBC coverage on new features
4. Documentation updated

---

## Implementation Roadmap

### Phase 1: Core Extensions (Priority 1)
**Add to SIMPLE_LIST_EXTENSIONS**:
- min_by, max_by
- index_of_first, index_of_last

**Tests**: 8 new tests
**Estimated LOC**: ~80

### Phase 2: Sorted Extensions (Priority 2a)
**Create SIMPLE_SORTABLE_LIST_EXTENSIONS**:
- sorted_by, sorted_by_descending

**Tests**: 4 new tests
**Estimated LOC**: ~60

### Phase 3: Hashable Extensions (Priority 2b)
**Create SIMPLE_HASHABLE_LIST_EXTENSIONS**:
- distinct, distinct_by

**Tests**: 4 new tests
**Estimated LOC**: ~50

### Phase 4: Advanced Operations (Priority 3)
**Add to SIMPLE_LIST_EXTENSIONS**:
- zip
- chunked, windowed

**Tests**: 6 new tests
**Estimated LOC**: ~80

---

## Resource Requirements

**Skills Needed**:
- Eiffel generics and type constraints
- Functional programming patterns
- Design by Contract

**Dependencies**:
- ISE base library (SORTER classes for sorting)
- Existing simple_container classes

---

## Success Metrics

| Metric | Target |
|--------|--------|
| All tests pass | 100% |
| New feature tests | 22+ new tests |
| Contract coverage | 100% of new features |
| Documentation | README updated, examples added |

---

## Appendix: Research Documents

- [7S-01-SCOPE.md](./7S-01-SCOPE.md) - Problem definition
- [7S-02-LANDSCAPE.md](./7S-02-LANDSCAPE.md) - Existing solutions analysis
- [7S-03-REQUIREMENTS.md](./7S-03-REQUIREMENTS.md) - Detailed requirements
- [7S-04-DECISIONS.md](./7S-04-DECISIONS.md) - Design decisions
- [7S-05-INNOVATIONS.md](./7S-05-INNOVATIONS.md) - Novel approaches
- [7S-06-RISKS.md](./7S-06-RISKS.md) - Risk analysis

---

## Sources

- [Java Stream API](https://docs.oracle.com/javase/8/docs/api/java/util/stream/Stream.html)
- [C# LINQ Documentation](https://learn.microsoft.com/en-us/dotnet/csharp/linq/)
- [Kotlin Collections](https://kotlinlang.org/docs/collection-parts.html)
- [Kotlin Windowing Article](https://kt.academy/article/fk-cp-windowing)

---

*Research completed: 2026-01-20*
*Recommendation: PROCEED*
*Ready for: Implementation*
