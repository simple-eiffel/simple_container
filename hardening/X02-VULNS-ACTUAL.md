# VULNERABILITY SCAN REPORT: simple_container

## Date: 2026-01-20

## Scan Summary
- Total vulnerabilities: 12
- Critical: 0
- High: 2
- Medium: 6
- Low: 4

## High Findings

### H1: Insertion Sort In-Place Modification
**Location:** `SIMPLE_SORTABLE_LIST_EXTENSIONS.insertion_sort:70-94`
**Pattern:** State corruption on exception
**Trigger:** If agent `a_key` raises exception mid-sort, list is left partially sorted
**Severity:** HIGH
**Details:** The insertion_sort modifies the list in-place. If the key selector agent raises an exception during comparison (line 72, 75), the list will be left in an inconsistent partially-sorted state.

### H2: Concurrency Unsafe Sorting
**Location:** `SIMPLE_SORTABLE_LIST_EXTENSIONS.insertion_sort`
**Pattern:** Non-atomic compound operation
**Trigger:** Multiple threads calling sorted_by on same source list
**Severity:** HIGH
**Details:** While sorted_by creates a copy, if two threads try to sort lists that share underlying storage, race conditions can occur. No SCOOP separate annotations.

## Medium Findings

### M1: Detachable Return Without Postcondition
**Location:** `SIMPLE_LIST_EXTENSIONS.min_by:69-84`, `max_by:86-101`
**Pattern:** Contract gap
**Trigger:** Caller assumes non-Void result without checking
**Severity:** MEDIUM
**Details:** Returns detachable G but no postcondition guarantees that when Result is attached, it's actually from the target list.
**Should have:** `result_from_list: Result /= Void implies target.has (Result)`

### M2: Folded Operation Type Safety
**Location:** `SIMPLE_LIST_QUERY.folded:109-118`
**Pattern:** Type confusion
**Trigger:** Combiner returns incompatible type
**Severity:** MEDIUM
**Details:** The combiner function signature is `FUNCTION [ANY, G, ANY]`. No validation that the combiner's return type is compatible with its first parameter type across iterations.

### M3: Group By Hash Collision
**Location:** `SIMPLE_LIST_EXTENSIONS.group_by:46-65`
**Pattern:** Logic error potential
**Trigger:** Items with hash collisions in key function
**Severity:** MEDIUM
**Details:** Uses HASH_TABLE internally. If key function produces colliding hashes for different logical keys, groups may be incorrect. The postcondition only checks `result_exists`.

### M4: Slice Sub-Slice Index Calculation
**Location:** `SIMPLE_SLICE.sub_slice:142-153`
**Pattern:** Off-by-one potential
**Trigger:** Edge case slicing at boundaries
**Severity:** MEDIUM
**Details:** `create Result.make (source, start_index + a_start - 1, start_index + a_end - 1)` - complex index math could have edge cases. Postcondition only checks count.

### M5: Zip Length Mismatch Silent Truncation
**Location:** `SIMPLE_LIST_EXTENSIONS.zip:231-248`
**Pattern:** Logic error - silent data loss
**Trigger:** Lists of different lengths
**Severity:** MEDIUM
**Details:** When lists have different lengths, zip silently truncates to shorter length. No warning or alternative behavior. Caller may lose data unknowingly.

### M6: Split Converter Exception
**Location:** `SIMPLE_STRING_CONVERSIONS.split_to_list:47-63`
**Pattern:** External function exception
**Trigger:** Converter function raises exception on malformed input
**Severity:** MEDIUM
**Details:** If `a_converter.item ([ic])` raises exception, partial results are lost. No error handling or rescue clause.

## Low Findings

### L1: Empty List Min/Max Returns Void
**Location:** `SIMPLE_LIST_EXTENSIONS.min_by`, `max_by`
**Pattern:** Empty input handling
**Trigger:** Empty list input
**Severity:** LOW
**Details:** Returns Void on empty list. Behavior is correct but undocumented in postcondition. Callers must handle Void.

### L2: Chunked Last Chunk Size
**Location:** `SIMPLE_LIST_EXTENSIONS.chunked:252-276`
**Pattern:** Logic awareness
**Trigger:** List size not divisible by chunk size
**Severity:** LOW
**Details:** Last chunk may be smaller. Documented in comment but not in postcondition about last chunk.

### L3: Cursor Guard Restoration Failure
**Location:** `SIMPLE_CURSOR_GUARD.restore:27-35`
**Pattern:** Silent failure
**Trigger:** Cursor becomes invalid between save and restore
**Severity:** LOW
**Details:** If `valid_cursor (l_cursor)` returns False, restoration silently skips. Caller is unaware.

### L4: String Conversions Void Item
**Location:** `SIMPLE_STRING_CONVERSIONS.item_to_string:67-77`
**Pattern:** Void handling
**Trigger:** List contains Void item (if G is detachable)
**Severity:** LOW
**Details:** Handles Void by returning "Void" string. May not be desired behavior for all use cases.

## Attack Plan

Based on vulnerabilities found, the attack plan for X03-X04:

1. **First assault**: `insertion_sort` exception path - inject failing key selector
2. **Second assault**: `min_by`/`max_by` Void handling - verify Void on empty list
3. **Third assault**: `zip` truncation - verify data loss on mismatched lengths
4. **Fourth assault**: `split_to_list` converter exception - inject failing converter
5. **Fifth assault**: `sub_slice` boundary math - edge case indices
6. **Sixth assault**: `group_by` key collision - verify correct grouping

## Recommended Defenses (for later)

1. **For insertion_sort**: Consider copying list first, sorting copy, to avoid partial state on exception
2. **For min_by/max_by**: Add postcondition `empty_means_void: target.is_empty implies Result = Void`
3. **For zip**: Consider alternative API `zip_strict` that requires same length
4. **For split_to_list**: Add rescue clause returning partial results or empty list
5. **For sub_slice**: Add postcondition verifying first/last item values
6. **For group_by**: Add postcondition about total item count preservation

## VERIFICATION CHECKPOINT

- All 10 vulnerability patterns scanned: YES
- Findings prioritized by severity: YES
- Attack plan for next phase established: YES
- Defensive recommendations prepared: YES
