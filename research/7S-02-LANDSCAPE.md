# 7S-02: Landscape - simple_container Improvements

## Date: 2026-01-20

---

## Existing Solutions Inventory

### Java Streams API (java.util.stream.Stream)
| Aspect | Assessment |
|--------|------------|
| Maturity | MATURE (since Java 8, 2014) |
| Relevance | 90% |
| Documentation | https://docs.oracle.com/javase/8/docs/api/java/util/stream/Stream.html |

**Operations relevant to our gaps**:
- `sorted()` - Natural order or with Comparator
- `distinct()` - Using Object.equals()
- `min(Comparator)` / `max(Comparator)` - Returns Optional
- `findFirst()` - Returns Optional
- `flatMap()` - For nested collections

**Strengths**:
+ Comprehensive API
+ Well-documented
+ Lazy evaluation
+ Parallel streams support

**Weaknesses**:
- No chunked/windowed
- No indexed operations
- Verbose Comparator syntax

---

### C# LINQ (System.Linq)
| Aspect | Assessment |
|--------|------------|
| Maturity | MATURE (since C# 3.0, 2007) |
| Relevance | 90% |
| Documentation | https://learn.microsoft.com/en-us/dotnet/csharp/linq/ |

**Operations relevant to our gaps**:
- `OrderBy()` / `OrderByDescending()` / `ThenBy()`
- `Distinct()` - With optional IEqualityComparer
- `Min()` / `Max()` / `MinBy()` / `MaxBy()`
- `Zip()` - Combines two sequences
- `SelectMany()` - Flatten operation
- `GroupBy()` - Grouping

**Strengths**:
+ SQL-like query syntax option
+ Very comprehensive
+ Good integration with language

**Weaknesses**:
- No chunked/windowed natively
- Requires extension methods for some operations

---

### Kotlin Collections (kotlin.collections)
| Aspect | Assessment |
|--------|------------|
| Maturity | MATURE (Kotlin 1.0, 2016) |
| Relevance | 95% |
| Documentation | https://kotlinlang.org/docs/collection-parts.html |

**Operations relevant to our gaps**:
- `sorted()` / `sortedBy()` / `sortedDescending()`
- `distinct()` / `distinctBy()`
- `minOrNull()` / `maxOrNull()` / `minByOrNull()` / `maxByOrNull()`
- `indexOfFirst()` / `indexOfLast()`
- `zip()` / `zipWithNext()`
- `flatten()` / `flatMap()`
- `chunked()` - **Innovative!** Split into fixed-size groups
- `windowed()` - **Innovative!** Sliding window

**Strengths**:
+ Most comprehensive of all
+ Null-safe by design (OrNull variants)
+ chunked/windowed unique features
+ Modern, clean API

**Weaknesses**:
- Some operations only work on specific collection types

---

## Comparison Matrix

| Operation | Java | C# LINQ | Kotlin | simple_container |
|-----------|------|---------|--------|------------------|
| sorted | ✓ | ✓ | ✓ | ✗ |
| distinct | ✓ | ✓ | ✓ | ✗ |
| min/max | ✓ | ✓ | ✓ | ✗ |
| find_index | ✗* | ✓ | ✓ | ✗ |
| zip | ✗* | ✓ | ✓ | ✗ |
| flatten | ✓ | ✓ | ✓ | ✗ |
| chunked | ✗ | ✗ | ✓ | ✗ |
| windowed | ✗ | ✗ | ✓ | ✗ |
| filter | ✓ | ✓ | ✓ | ✓ |
| map | ✓ | ✓ | ✓ | ✓ |
| fold/reduce | ✓ | ✓ | ✓ | ✓ |
| partition | ✗ | ✗* | ✓ | ✓ |
| take/drop | ✓ | ✓ | ✓ | ✓ |

*Note: ✗* means available with workarounds or extension methods

---

## Patterns Identified

### Pattern: Null-Safe Returns
**Seen in**: Kotlin (minOrNull, maxOrNull, firstOrNull)
**Description**: Return null/Void instead of throwing on empty
**Adopt**: YES - matches Eiffel's detachable pattern

### Pattern: By-Selector Variants
**Seen in**: All (minBy, maxBy, sortedBy, distinctBy)
**Description**: Operations that take a key selector function
**Adopt**: YES - adds flexibility

### Pattern: Lazy Evaluation
**Seen in**: Java Streams, LINQ
**Description**: Operations don't execute until terminal operation
**Adopt**: NO - would require architecture change

### Pattern: Chunked/Windowed
**Seen in**: Kotlin only
**Description**: Split collection into fixed-size groups or sliding windows
**Adopt**: YES - innovative feature gap

---

## Eiffel Ecosystem Check

### ISE Base Library
- ARRAYED_LIST has `sort` via SORTER classes
- No functional-style sorted that returns new list
- No distinct, min_by, max_by, etc.

### Simple Eiffel Ecosystem
- simple_container is the only functional collection library
- No overlapping libraries

---

## Build vs Adapt Assessment

| Option | Effort | Risk | Fit |
|--------|--------|------|-----|
| BUILD (add to existing) | LOW | LOW | 100% |
| BUY | N/A | N/A | N/A |
| ADAPT (from other Eiffel) | N/A | N/A | N/A |

**Recommendation**: BUILD - Add features to existing SIMPLE_LIST_EXTENSIONS and SIMPLE_LIST_QUERY classes.

---

## Lessons Learned

### DO
- Use null-safe return patterns (detachable for empty cases)
- Provide both simple and by-selector variants (min and min_by)
- Follow existing API naming conventions
- Return new collections, don't modify originals

### DON'T
- Don't add operations requiring type constraints to classes without constraints
- Don't break existing API
- Don't implement lazy evaluation (too complex for scope)

---

## Sources

- [Java Stream API Documentation](https://docs.oracle.com/javase/8/docs/api/java/util/stream/Stream.html)
- [C# LINQ GroupBy](https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable.groupby)
- [C# LINQ Zip](https://dotnettutorials.net/lesson/linq-zip-method/)
- [Kotlin Collection Parts](https://kotlinlang.org/docs/collection-parts.html)
- [Kotlin Windowing, Zipping and Chunking](https://kt.academy/article/fk-cp-windowing)
- [Advanced Kotlin Collection Functionality](https://dev.to/kotlin/advanced-kotlin-collection-functionality-5e90)
