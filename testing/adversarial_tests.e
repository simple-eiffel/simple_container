note
	description: "Adversarial tests for simple_container - edge cases and boundary conditions"

class
	ADVERSARIAL_TESTS

feature -- Edge Case Tests

	test_empty_list_operations
			-- Test operations on empty lists
		local
			l_list: ARRAYED_LIST [INTEGER]
			l_query: SIMPLE_LIST_QUERY [INTEGER]
			l_ext: SIMPLE_LIST_EXTENSIONS [INTEGER]
			l_cond: SIMPLE_PREDICATE_CONDITION [INTEGER]
			l_str_list: ARRAYED_LIST [STRING]
			l_str_query: SIMPLE_LIST_QUERY [STRING]
			l_str_cond: SIMPLE_PREDICATE_CONDITION [STRING]
		do
			create l_list.make (0)
			create l_query.make (l_list)
			create l_ext.make (l_list)
			create l_cond.make (agent (i: INTEGER): BOOLEAN do Result := i > 0 end)

			-- Empty list filtering should return empty list
			assert ("empty_filtered", l_query.filtered (l_cond).is_empty)

			-- Test first_satisfying returns Void on empty list using reference type
			create l_str_list.make (0)
			create l_str_query.make (l_str_list)
			create l_str_cond.make (agent (s: STRING): BOOLEAN do Result := s.count > 0 end)
			assert ("empty_first_void", l_str_query.first_satisfying (l_str_cond) = Void)

			-- all_satisfy on empty list is True (vacuous truth)
			assert ("empty_all_satisfy", l_query.all_satisfy (l_cond))

			-- any_satisfies on empty list is False
			assert ("empty_any_false", not l_query.any_satisfies (l_cond))

			-- count_satisfying on empty is 0
			assert_integers_equal ("empty_count", 0, l_query.count_satisfying (l_cond))

			-- partition empty list
			assert ("empty_partition_sat", l_ext.partition (l_cond).satisfying.is_empty)
			assert ("empty_partition_not", l_ext.partition (l_cond).not_satisfying.is_empty)

			-- reversed empty list
			assert ("empty_reversed", l_ext.reversed.is_empty)

			-- take/drop on empty
			assert ("empty_take", l_ext.take (5).is_empty)
			assert ("empty_drop", l_ext.drop (5).is_empty)
		end

	test_single_element_list
			-- Test operations on single-element lists
		local
			l_list: ARRAYED_LIST [INTEGER]
			l_query: SIMPLE_LIST_QUERY [INTEGER]
			l_ext: SIMPLE_LIST_EXTENSIONS [INTEGER]
			l_cond: SIMPLE_PREDICATE_CONDITION [INTEGER]
		do
			create l_list.make_from_array (<<42>>)
			create l_query.make (l_list)
			create l_ext.make (l_list)
			create l_cond.make (agent (i: INTEGER): BOOLEAN do Result := i > 0 end)

			-- Filter single matching
			assert ("single_filtered", l_query.filtered (l_cond).count = 1)

			-- first_satisfying finds it
			if attached l_query.first_satisfying (l_cond) as l_found then
				assert_integers_equal ("single_first", 42, l_found)
			else
				assert ("single_should_find", False)
			end

			-- reversed single element
			assert ("single_rev_first", l_ext.reversed.first = 42)

			-- take more than exists
			assert ("single_take_3", l_ext.take (3).count = 1)

			-- drop more than exists
			assert ("single_drop_3", l_ext.drop (3).is_empty)
		end

	test_slice_boundaries
			-- Test slice with various boundary conditions
		local
			l_arr: ARRAY [INTEGER]
			l_slice: SIMPLE_SLICE [INTEGER]
		do
			l_arr := <<1, 2, 3, 4, 5>>

			-- Slice entire array
			create l_slice.make (l_arr, 1, 5)
			assert_integers_equal ("full_slice_count", 5, l_slice.count)

			-- Slice single element
			create l_slice.make (l_arr, 3, 3)
			assert_integers_equal ("single_slice_count", 1, l_slice.count)
			assert_integers_equal ("single_slice_val", 3, l_slice.first)

			-- Empty slice (start > end is valid with start = end + 1)
			create l_slice.make (l_arr, 3, 2)
			assert ("empty_slice", l_slice.is_empty)
		end

	test_set_operations_empty
			-- Test set operations with empty collections
		local
			l_ops: SIMPLE_SET_OPERATIONS [INTEGER]
			l_empty, l_full: ARRAYED_LIST [INTEGER]
			l_result: ARRAYED_SET [INTEGER]
		do
			create l_ops
			create l_empty.make (0)
			create l_full.make_from_array (<<1, 2, 3>>)

			-- Union with empty
			l_result := l_ops.union (l_empty, l_full)
			assert_integers_equal ("union_empty_first", 3, l_result.count)

			l_result := l_ops.union (l_full, l_empty)
			assert_integers_equal ("union_empty_second", 3, l_result.count)

			-- Intersection with empty
			l_result := l_ops.intersection (l_empty, l_full)
			assert ("inter_empty", l_result.is_empty)

			-- Difference with empty
			l_result := l_ops.difference (l_full, l_empty)
			assert_integers_equal ("diff_empty_second", 3, l_result.count)

			l_result := l_ops.difference (l_empty, l_full)
			assert ("diff_empty_first", l_result.is_empty)

			-- Subset with empty
			assert ("empty_subset_any", l_ops.is_subset (l_empty, l_full))
			assert ("not_full_subset_empty", not l_ops.is_subset (l_full, l_empty))

			-- Disjoint
			assert ("empty_disjoint", l_ops.is_disjoint (l_empty, l_full))
		end

	test_string_conversions_edge_cases
			-- Test string conversion edge cases
		local
			l_conv: SIMPLE_STRING_CONVERSIONS [INTEGER]
			l_empty, l_single: ARRAYED_LIST [INTEGER]
			l_result: STRING_32
		do
			create l_conv
			create l_empty.make (0)
			create l_single.make_from_array (<<42>>)

			-- Join empty list
			l_result := l_conv.joined (l_empty, ", ")
			assert ("empty_joined", l_result.is_empty)

			-- Join single element (no separator added)
			l_result := l_conv.joined (l_single, ", ")
			assert_strings_equal ("single_joined", "42", l_result)
		end

	test_condition_composition_complex
			-- Test complex condition composition
		local
			l_a, l_b, l_c: SIMPLE_PREDICATE_CONDITION [INTEGER]
			l_complex: SIMPLE_QUERY_CONDITION [INTEGER]
		do
			-- a: x > 5
			create l_a.make (agent (i: INTEGER): BOOLEAN do Result := i > 5 end)
			-- b: x < 10
			create l_b.make (agent (i: INTEGER): BOOLEAN do Result := i < 10 end)
			-- c: x is even
			create l_c.make (agent (i: INTEGER): BOOLEAN do Result := i \\ 2 = 0 end)

			-- Complex: (a AND b) OR NOT c  = (x > 5 AND x < 10) OR (x is odd)
			l_complex := (l_a and l_b) or (not l_c)

			-- Test cases:
			-- 7: (True AND True) OR False = True
			assert ("complex_7", l_complex.satisfied_by (7))

			-- 3: (False AND True) OR True = True (3 is odd)
			assert ("complex_3", l_complex.satisfied_by (3))

			-- 4: (False AND True) OR False = False (4 <= 5, 4 is even)
			assert ("complex_4", not l_complex.satisfied_by (4))

			-- 12: (True AND False) OR False = False (12 >= 10, 12 is even)
			assert ("complex_12", not l_complex.satisfied_by (12))
		end

	test_take_drop_boundaries
			-- Test take/drop with boundary values
		local
			l_list: ARRAYED_LIST [INTEGER]
			l_ext: SIMPLE_LIST_EXTENSIONS [INTEGER]
		do
			create l_list.make_from_array (<<1, 2, 3, 4, 5>>)
			create l_ext.make (l_list)

			-- take(0) should return empty
			assert ("take_0", l_ext.take (0).is_empty)

			-- drop(0) should return all
			assert_integers_equal ("drop_0", 5, l_ext.drop (0).count)

			-- take(exact) should return all
			assert_integers_equal ("take_exact", 5, l_ext.take (5).count)

			-- drop(exact) should return empty
			assert ("drop_exact", l_ext.drop (5).is_empty)

			-- take(more) should return all
			assert_integers_equal ("take_more", 5, l_ext.take (100).count)

			-- drop(more) should return empty
			assert ("drop_more", l_ext.drop (100).is_empty)
		end

feature -- New Feature Adversarial Tests (Phase 3 Extensions)

	test_min_max_empty_list
			-- min_by and max_by on empty list should return Void
		local
			l_ext: SIMPLE_LIST_EXTENSIONS [STRING]
			l_list: ARRAYED_LIST [STRING]
		do
			create l_list.make (0)
			create l_ext.make (l_list)
			assert ("min_empty_void", l_ext.min_by (agent (s: STRING): INTEGER do Result := s.count end) = Void)
			assert ("max_empty_void", l_ext.max_by (agent (s: STRING): INTEGER do Result := s.count end) = Void)
		end

	test_min_max_single_element
			-- min_by and max_by on single element should return that element
		local
			l_ext: SIMPLE_LIST_EXTENSIONS [STRING]
			l_list: ARRAYED_LIST [STRING]
		do
			create l_list.make_from_array (<<"only">>)
			create l_ext.make (l_list)
			if attached l_ext.min_by (agent (s: STRING): INTEGER do Result := s.count end) as l_min then
				assert_strings_equal ("min_single", "only", l_min)
			else
				assert ("min_single_attached", False)
			end
			if attached l_ext.max_by (agent (s: STRING): INTEGER do Result := s.count end) as l_max then
				assert_strings_equal ("max_single", "only", l_max)
			else
				assert ("max_single_attached", False)
			end
		end

	test_min_max_all_equal
			-- min_by and max_by when all elements have same key
		local
			l_ext: SIMPLE_LIST_EXTENSIONS [STRING]
			l_list: ARRAYED_LIST [STRING]
		do
			create l_list.make_from_array (<<"aa", "bb", "cc">>)
			create l_ext.make (l_list)
			-- All have length 2, should return first for both
			if attached l_ext.min_by (agent (s: STRING): INTEGER do Result := s.count end) as l_min then
				assert_strings_equal ("min_equal_first", "aa", l_min)
			else
				assert ("min_equal_attached", False)
			end
		end

	test_zip_different_lengths
			-- zip with different length lists truncates to shorter
		local
			l_ext: SIMPLE_LIST_EXTENSIONS [INTEGER]
			l_list1: ARRAYED_LIST [INTEGER]
			l_list2: ARRAYED_LIST [STRING]
			l_result: ARRAYED_LIST [TUPLE [first: INTEGER; second: ANY]]
		do
			create l_list1.make_from_array (<<1, 2, 3, 4, 5>>)
			create l_list2.make_from_array (<<"a", "b">>)
			create l_ext.make (l_list1)
			l_result := l_ext.zip (l_list2)
			assert_integers_equal ("zip_truncates", 2, l_result.count)
		end

	test_zip_empty_second_list
			-- zip with empty second list returns empty
		local
			l_ext: SIMPLE_LIST_EXTENSIONS [INTEGER]
			l_list1: ARRAYED_LIST [INTEGER]
			l_list2: ARRAYED_LIST [STRING]
			l_result: ARRAYED_LIST [TUPLE [first: INTEGER; second: ANY]]
		do
			create l_list1.make_from_array (<<1, 2, 3>>)
			create l_list2.make (0)
			create l_ext.make (l_list1)
			l_result := l_ext.zip (l_list2)
			assert ("zip_empty_other", l_result.is_empty)
		end

	test_chunked_larger_than_list
			-- chunked with size larger than list returns single chunk
		local
			l_ext: SIMPLE_LIST_EXTENSIONS [INTEGER]
			l_list: ARRAYED_LIST [INTEGER]
			l_result: ARRAYED_LIST [ARRAYED_LIST [INTEGER]]
		do
			create l_list.make_from_array (<<1, 2, 3>>)
			create l_ext.make (l_list)
			l_result := l_ext.chunked (10)
			assert_integers_equal ("chunked_big_one_chunk", 1, l_result.count)
			assert_integers_equal ("chunked_big_all_items", 3, l_result [1].count)
		end

	test_chunked_exact_division
			-- chunked where list divides evenly
		local
			l_ext: SIMPLE_LIST_EXTENSIONS [INTEGER]
			l_list: ARRAYED_LIST [INTEGER]
			l_result: ARRAYED_LIST [ARRAYED_LIST [INTEGER]]
		do
			create l_list.make_from_array (<<1, 2, 3, 4, 5, 6>>)
			create l_ext.make (l_list)
			l_result := l_ext.chunked (2)
			assert_integers_equal ("chunked_exact_chunks", 3, l_result.count)
			assert ("chunked_exact_all_same", l_result [1].count = 2 and l_result [2].count = 2 and l_result [3].count = 2)
		end

	test_windowed_small_list
			-- windowed with window larger than list returns empty
		local
			l_ext: SIMPLE_LIST_EXTENSIONS [INTEGER]
			l_list: ARRAYED_LIST [INTEGER]
			l_result: ARRAYED_LIST [ARRAYED_LIST [INTEGER]]
		do
			create l_list.make_from_array (<<1, 2>>)
			create l_ext.make (l_list)
			l_result := l_ext.windowed (5)
			assert ("windowed_too_big", l_result.is_empty)
		end

	test_sorted_by_empty
			-- sorted_by on empty list returns empty
		local
			l_ext: SIMPLE_SORTABLE_LIST_EXTENSIONS [INTEGER]
			l_list: ARRAYED_LIST [INTEGER]
		do
			create l_list.make (0)
			create l_ext.make (l_list)
			assert ("sorted_empty", l_ext.sorted_by (agent (i: INTEGER): INTEGER do Result := i end).is_empty)
		end

	test_sorted_by_single
			-- sorted_by on single element returns same element
		local
			l_ext: SIMPLE_SORTABLE_LIST_EXTENSIONS [INTEGER]
			l_list: ARRAYED_LIST [INTEGER]
			l_result: ARRAYED_LIST [INTEGER]
		do
			create l_list.make_from_array (<<42>>)
			create l_ext.make (l_list)
			l_result := l_ext.sorted_by (agent (i: INTEGER): INTEGER do Result := i end)
			assert_integers_equal ("sorted_single_count", 1, l_result.count)
			assert_integers_equal ("sorted_single_value", 42, l_result [1])
		end

	test_distinct_all_duplicates
			-- distinct on all-same list returns single element
		local
			l_ext: SIMPLE_HASHABLE_LIST_EXTENSIONS [INTEGER]
			l_list: ARRAYED_LIST [INTEGER]
		do
			create l_list.make_from_array (<<5, 5, 5, 5, 5>>)
			create l_ext.make (l_list)
			assert_integers_equal ("distinct_all_same", 1, l_ext.distinct.count)
		end

	test_distinct_preserves_order
			-- distinct preserves first occurrence order
		local
			l_ext: SIMPLE_HASHABLE_LIST_EXTENSIONS [INTEGER]
			l_list: ARRAYED_LIST [INTEGER]
			l_result: ARRAYED_LIST [INTEGER]
		do
			create l_list.make_from_array (<<3, 1, 2, 1, 3, 2>>)
			create l_ext.make (l_list)
			l_result := l_ext.distinct
			assert_integers_equal ("distinct_order_count", 3, l_result.count)
			assert_integers_equal ("distinct_order_1", 3, l_result [1])
			assert_integers_equal ("distinct_order_2", 1, l_result [2])
			assert_integers_equal ("distinct_order_3", 2, l_result [3])
		end

	test_index_of_not_found
			-- index_of_first/last returns 0 when not found
		local
			l_ext: SIMPLE_LIST_EXTENSIONS [INTEGER]
			l_list: ARRAYED_LIST [INTEGER]
			l_cond: SIMPLE_PREDICATE_CONDITION [INTEGER]
		do
			create l_list.make_from_array (<<1, 2, 3>>)
			create l_ext.make (l_list)
			create l_cond.make (agent (i: INTEGER): BOOLEAN do Result := i > 100 end)
			assert_integers_equal ("index_first_not_found", 0, l_ext.index_of_first (l_cond))
			assert_integers_equal ("index_last_not_found", 0, l_ext.index_of_last (l_cond))
		end

feature {NONE} -- Assertions

	assert (a_tag: STRING; a_condition: BOOLEAN)
		local
			l_ex: DEVELOPER_EXCEPTION
		do
			if not a_condition then
				create l_ex
				l_ex.set_description (a_tag + ": Assertion failed")
				l_ex.raise
			end
		end

	assert_integers_equal (a_tag: STRING; a_expected, a_actual: INTEGER)
		local
			l_ex: DEVELOPER_EXCEPTION
		do
			if a_expected /= a_actual then
				create l_ex
				l_ex.set_description (a_tag + ": expected " + a_expected.out + " but got " + a_actual.out)
				l_ex.raise
			end
		end

	assert_strings_equal (a_tag: STRING; a_expected, a_actual: READABLE_STRING_GENERAL)
		local
			l_ex: DEVELOPER_EXCEPTION
		do
			if not a_expected.same_string (a_actual) then
				create l_ex
				l_ex.set_description (a_tag + ": expected '" + a_expected.out + "' but got '" + a_actual.out + "'")
				l_ex.raise
			end
		end

end
