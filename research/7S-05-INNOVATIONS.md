# 7S-05: Innovations - simple_container Improvements

## Date: 2026-01-20

---

## Innovation Summary

| ID | Innovation | Type | Novelty | Value |
|----|------------|------|---------|-------|
| I-001 | Chunked/Windowed in Eiffel | FEATURE | New to Eiffel | HIGH |
| I-002 | DBC on all functional ops | DESIGN | New to functional | MEDIUM |
| I-003 | Agent-based key selectors | APPROACH | Eiffel-specific | HIGH |

---

## Value Proposition

**For**: Eiffel developers working with collections
**Who need**: Functional-style operations without manual iteration
**Our solution**: Comprehensive set of operations with full DBC
**Unlike**: ISE base library or manual implementation
**Provides**: Safety, clarity, and productivity

---

## Unique Selling Points

1. **Full Design by Contract**: Every operation has preconditions, postconditions
2. **Kotlin-inspired Operations**: chunked/windowed not available in Java/C# stdlib
3. **Cursor-Safe**: All operations use across, never modify cursor
4. **SCOOP-Compatible**: Safe for concurrent use

---

## Key Innovations

### I-001: Chunked/Windowed Operations in Eiffel

**Type**: FEATURE

**Description**: Adding chunked() and windowed() operations inspired by Kotlin. These are NOT available in Java Streams or C# LINQ standard libraries.

**Problem Solved**: Developers often need to process collections in fixed-size batches (chunked) or with sliding windows (windowed). Without these, manual loop management is required.

**Novelty**:
- New to world: NO (Kotlin has it)
- New to Eiffel: YES
- New to Simple ecosystem: YES

**Value**: High - enables patterns like:
```eiffel
-- Process items in batches of 10
across l_ext.chunked (10) as batch loop
  process_batch (batch)
end

-- Compare adjacent pairs
across l_ext.windowed (2) as pair loop
  compare (pair[1], pair[2])
end
```

---

### I-002: Full DBC on Functional Operations

**Type**: DESIGN

**Description**: Unlike Java Streams or LINQ which rely on exceptions, our operations have explicit contracts.

**Eiffel Advantage**: Design by Contract is native to Eiffel. We can specify:
- Preconditions: What inputs are valid
- Postconditions: What outputs are guaranteed
- Invariants: What always holds

**Example**:
```eiffel
chunked (a_size: INTEGER): ARRAYED_LIST [ARRAYED_LIST [G]]
  require
    positive_size: a_size > 0
  ensure
    result_exists: Result /= Void
    covers_all: across Result as chunk all chunk.count <= a_size end
    last_may_be_smaller: Result.last.count <= a_size
```

**Value**: Medium-High - catches errors at contract check time, not deep in processing.

---

### I-003: Agent-Based Key Selectors

**Type**: APPROACH

**Description**: Using Eiffel agents for key selection functions provides type-safe, composable selectors.

**Comparison**:
- Java: `Comparator.comparing(Person::getAge)` - method references
- C#: `OrderBy(p => p.Age)` - lambda expressions
- Eiffel: `agent (p: PERSON): INTEGER do Result := p.age end` - agents

**Eiffel-Specific Advantage**: Agents are first-class objects with full type checking at compile time.

**Value**: High - enables compile-time type safety for selector functions.

---

## Differentiation from Alternatives

| Aspect | Java Streams | C# LINQ | Kotlin | Ours |
|--------|--------------|---------|--------|------|
| Chunked | ✗ | ✗ | ✓ | ✓ |
| Windowed | ✗ | ✗ | ✓ | ✓ |
| DBC | ✗ | ✗ | ✗ | ✓ |
| Void Safety | Optional | Nullable | Nullable | Native |
| Cursor Safety | N/A | N/A | N/A | ✓ |

---

## Eiffel-Specific Advantages

1. **Void Safety**: Detachable types make null-safety explicit
2. **Agents**: First-class functions with full type checking
3. **Design by Contract**: Explicit preconditions and postconditions
4. **SCOOP**: Built-in concurrency safety with `across`
5. **Multiple Inheritance**: Could add operations as mix-ins (future)

---

## Innovation Risks

| Innovation | Risk | Mitigation |
|------------|------|------------|
| I-001 Chunked/Windowed | Unfamiliar to Eiffel devs | Good documentation, examples |
| I-002 Heavy DBC | Contract overhead | Minimal runtime cost for assertions |
| I-003 Agent selectors | Verbose syntax | Provide common predefined agents |

---

## Competitive Moat

**Why can't others copy**: The implementation is MIT licensed (open), but:
1. Eiffel-specific patterns (DBC, void safety) require Eiffel
2. simple_* ecosystem integration provides value
3. Consistent API across ecosystem

**Advantage duration**: Permanent within Eiffel ecosystem
