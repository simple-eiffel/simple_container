note
	description: "Tests for simple_container library"

class
	LIB_TESTS

inherit
	ANY
		redefine
			default_create
		end

feature {NONE} -- Initialization

	default_create
		do
		end

feature -- Condition Tests

	test_predicate_condition
			-- Test predicate-based condition
		local
			l_cond: SIMPLE_PREDICATE_CONDITION [INTEGER]
		do
			create l_cond.make (agent (i: INTEGER): BOOLEAN do Result := i > 5 end)
			assert ("gt_5_true", l_cond.satisfied_by (10))
			assert ("gt_5_false", not l_cond.satisfied_by (3))
		end

	test_and_condition
			-- Test AND condition
		local
			l_gt5: SIMPLE_PREDICATE_CONDITION [INTEGER]
			l_lt10: SIMPLE_PREDICATE_CONDITION [INTEGER]
			l_combined: SIMPLE_AND_CONDITION [INTEGER]
		do
			create l_gt5.make (agent (i: INTEGER): BOOLEAN do Result := i > 5 end)
			create l_lt10.make (agent (i: INTEGER): BOOLEAN do Result := i < 10 end)
			l_combined := l_gt5 and l_lt10
			assert ("and_true", l_combined.satisfied_by (7))
			assert ("and_false_low", not l_combined.satisfied_by (3))
			assert ("and_false_high", not l_combined.satisfied_by (15))
		end

	test_or_condition
			-- Test OR condition
		local
			l_lt3: SIMPLE_PREDICATE_CONDITION [INTEGER]
			l_gt7: SIMPLE_PREDICATE_CONDITION [INTEGER]
			l_combined: SIMPLE_OR_CONDITION [INTEGER]
		do
			create l_lt3.make (agent (i: INTEGER): BOOLEAN do Result := i < 3 end)
			create l_gt7.make (agent (i: INTEGER): BOOLEAN do Result := i > 7 end)
			l_combined := l_lt3 or l_gt7
			assert ("or_true_low", l_combined.satisfied_by (1))
			assert ("or_true_high", l_combined.satisfied_by (10))
			assert ("or_false", not l_combined.satisfied_by (5))
		end

	test_not_condition
			-- Test NOT condition
		local
			l_positive: SIMPLE_PREDICATE_CONDITION [INTEGER]
			l_not_positive: SIMPLE_NOT_CONDITION [INTEGER]
		do
			create l_positive.make (agent (i: INTEGER): BOOLEAN do Result := i > 0 end)
			l_not_positive := not l_positive
			assert ("not_true", l_not_positive.satisfied_by (-5))
			assert ("not_false", not l_not_positive.satisfied_by (5))
		end

feature -- List Query Tests

	test_filtered
			-- Test filtering a list
		local
			l_list: ARRAYED_LIST [INTEGER]
			l_query: SIMPLE_LIST_QUERY [INTEGER]
			l_cond: SIMPLE_PREDICATE_CONDITION [INTEGER]
			l_result: ARRAYED_LIST [INTEGER]
		do
			create l_list.make_from_array (<<1, 2, 3, 4, 5, 6, 7, 8, 9, 10>>)
			create l_query.make (l_list)
			create l_cond.make (agent (i: INTEGER): BOOLEAN do Result := i > 5 end)
			l_result := l_query.filtered (l_cond)
			assert_integers_equal ("filtered_count", 5, l_result.count)
		end

	test_first_satisfying
			-- Test finding first matching item
		local
			l_list: ARRAYED_LIST [INTEGER]
			l_query: SIMPLE_LIST_QUERY [INTEGER]
			l_cond: SIMPLE_PREDICATE_CONDITION [INTEGER]
		do
			create l_list.make_from_array (<<1, 2, 3, 4, 5>>)
			create l_query.make (l_list)
			create l_cond.make (agent (i: INTEGER): BOOLEAN do Result := i > 3 end)
			if attached l_query.first_satisfying (l_cond) as l_found then
				assert_integers_equal ("first_gt3", 4, l_found)
			else
				assert ("should_find", False)
			end
		end

	test_all_satisfy
			-- Test if all items satisfy condition
		local
			l_list: ARRAYED_LIST [INTEGER]
			l_query: SIMPLE_LIST_QUERY [INTEGER]
			l_positive: SIMPLE_PREDICATE_CONDITION [INTEGER]
		do
			create l_list.make_from_array (<<1, 2, 3, 4, 5>>)
			create l_query.make (l_list)
			create l_positive.make (agent (i: INTEGER): BOOLEAN do Result := i > 0 end)
			assert ("all_positive", l_query.all_satisfy (l_positive))
		end

	test_any_satisfies
			-- Test if any item satisfies condition
		local
			l_list: ARRAYED_LIST [INTEGER]
			l_query: SIMPLE_LIST_QUERY [INTEGER]
			l_gt10: SIMPLE_PREDICATE_CONDITION [INTEGER]
		do
			create l_list.make_from_array (<<1, 2, 3, 4, 5>>)
			create l_query.make (l_list)
			create l_gt10.make (agent (i: INTEGER): BOOLEAN do Result := i > 10 end)
			assert ("none_gt10", not l_query.any_satisfies (l_gt10))
		end

	test_count_satisfying
			-- Test counting matching items
		local
			l_list: ARRAYED_LIST [INTEGER]
			l_query: SIMPLE_LIST_QUERY [INTEGER]
			l_even: SIMPLE_PREDICATE_CONDITION [INTEGER]
		do
			create l_list.make_from_array (<<1, 2, 3, 4, 5, 6>>)
			create l_query.make (l_list)
			create l_even.make (agent (i: INTEGER): BOOLEAN do Result := i \\ 2 = 0 end)
			assert_integers_equal ("even_count", 3, l_query.count_satisfying (l_even))
		end

feature -- Slice Tests

	test_slice_make
			-- Test slice creation
		local
			l_arr: ARRAY [STRING]
			l_slice: SIMPLE_SLICE [STRING]
		do
			l_arr := <<"a", "b", "c", "d", "e">>
			create l_slice.make (l_arr, 2, 4)
			assert_integers_equal ("slice_count", 3, l_slice.count)
		end

	test_slice_item
			-- Test slice item access
		local
			l_arr: ARRAY [STRING]
			l_slice: SIMPLE_SLICE [STRING]
		do
			l_arr := <<"a", "b", "c", "d", "e">>
			create l_slice.make (l_arr, 2, 4)
			assert_strings_equal ("slice_first", "b", l_slice.first)
			assert_strings_equal ("slice_last", "d", l_slice.last)
			assert_strings_equal ("slice_item_2", "c", l_slice [2])
		end

	test_slice_iteration
			-- Test slice iteration
		local
			l_arr: ARRAY [INTEGER]
			l_slice: SIMPLE_SLICE [INTEGER]
			l_sum: INTEGER
		do
			l_arr := <<1, 2, 3, 4, 5>>
			create l_slice.make (l_arr, 2, 4)
			across l_slice as ic loop
				l_sum := l_sum + ic
			end
			assert_integers_equal ("slice_sum", 9, l_sum)  -- 2+3+4
		end

	test_slice_to_array
			-- Test slice conversion to array
		local
			l_arr: ARRAY [INTEGER]
			l_slice: SIMPLE_SLICE [INTEGER]
			l_result: ARRAY [INTEGER]
		do
			l_arr := <<1, 2, 3, 4, 5>>
			create l_slice.make (l_arr, 2, 4)
			l_result := l_slice.to_array
			assert_integers_equal ("to_array_count", 3, l_result.count)
		end

feature -- Set Operation Tests

	test_union
			-- Test set union
		local
			l_ops: SIMPLE_SET_OPERATIONS [INTEGER]
			l_a, l_b: ARRAYED_LIST [INTEGER]
			l_result: ARRAYED_SET [INTEGER]
		do
			create l_ops
			create l_a.make_from_array (<<1, 2, 3>>)
			create l_b.make_from_array (<<3, 4, 5>>)
			l_result := l_ops.union (l_a, l_b)
			assert_integers_equal ("union_count", 5, l_result.count)
		end

	test_intersection
			-- Test set intersection
		local
			l_ops: SIMPLE_SET_OPERATIONS [INTEGER]
			l_a, l_b: ARRAYED_LIST [INTEGER]
			l_result: ARRAYED_SET [INTEGER]
		do
			create l_ops
			create l_a.make_from_array (<<1, 2, 3, 4>>)
			create l_b.make_from_array (<<3, 4, 5, 6>>)
			l_result := l_ops.intersection (l_a, l_b)
			assert_integers_equal ("intersection_count", 2, l_result.count)
			assert ("has_3", l_result.has (3))
			assert ("has_4", l_result.has (4))
		end

	test_difference
			-- Test set difference
		local
			l_ops: SIMPLE_SET_OPERATIONS [INTEGER]
			l_a, l_b: ARRAYED_LIST [INTEGER]
			l_result: ARRAYED_SET [INTEGER]
		do
			create l_ops
			create l_a.make_from_array (<<1, 2, 3, 4>>)
			create l_b.make_from_array (<<3, 4, 5>>)
			l_result := l_ops.difference (l_a, l_b)
			assert_integers_equal ("difference_count", 2, l_result.count)
			assert ("has_1", l_result.has (1))
			assert ("has_2", l_result.has (2))
		end

	test_is_subset
			-- Test subset check
		local
			l_ops: SIMPLE_SET_OPERATIONS [INTEGER]
			l_small, l_large: ARRAYED_LIST [INTEGER]
		do
			create l_ops
			create l_small.make_from_array (<<2, 3>>)
			create l_large.make_from_array (<<1, 2, 3, 4, 5>>)
			assert ("is_subset", l_ops.is_subset (l_small, l_large))
			assert ("not_subset", not l_ops.is_subset (l_large, l_small))
		end

feature -- String Conversion Tests

	test_joined
			-- Test joining items with separator
		local
			l_conv: SIMPLE_STRING_CONVERSIONS [INTEGER]
			l_list: ARRAYED_LIST [INTEGER]
			l_result: STRING_32
		do
			create l_conv
			create l_list.make_from_array (<<1, 2, 3>>)
			l_result := l_conv.joined (l_list, ", ")
			assert_strings_equal ("joined", "1, 2, 3", l_result)
		end

feature -- List Extension Tests

	test_partition
			-- Test partitioning a list
		local
			l_ext: SIMPLE_LIST_EXTENSIONS [INTEGER]
			l_list: ARRAYED_LIST [INTEGER]
			l_cond: SIMPLE_PREDICATE_CONDITION [INTEGER]
			l_result: TUPLE [satisfying: ARRAYED_LIST [INTEGER]; not_satisfying: ARRAYED_LIST [INTEGER]]
		do
			create l_list.make_from_array (<<1, 2, 3, 4, 5, 6>>)
			create l_ext.make (l_list)
			create l_cond.make (agent (i: INTEGER): BOOLEAN do Result := i \\ 2 = 0 end)
			l_result := l_ext.partition (l_cond)
			assert_integers_equal ("even_count", 3, l_result.satisfying.count)
			assert_integers_equal ("odd_count", 3, l_result.not_satisfying.count)
		end

	test_reversed
			-- Test reversing a list
		local
			l_ext: SIMPLE_LIST_EXTENSIONS [INTEGER]
			l_list: ARRAYED_LIST [INTEGER]
			l_result: ARRAYED_LIST [INTEGER]
		do
			create l_list.make_from_array (<<1, 2, 3>>)
			create l_ext.make (l_list)
			l_result := l_ext.reversed
			assert_integers_equal ("rev_first", 3, l_result [1])
			assert_integers_equal ("rev_last", 1, l_result [3])
		end

	test_take
			-- Test taking first n items
		local
			l_ext: SIMPLE_LIST_EXTENSIONS [INTEGER]
			l_list: ARRAYED_LIST [INTEGER]
			l_result: ARRAYED_LIST [INTEGER]
		do
			create l_list.make_from_array (<<1, 2, 3, 4, 5>>)
			create l_ext.make (l_list)
			l_result := l_ext.take (3)
			assert_integers_equal ("take_count", 3, l_result.count)
			assert_integers_equal ("take_last", 3, l_result [3])
		end

	test_drop
			-- Test dropping first n items
		local
			l_ext: SIMPLE_LIST_EXTENSIONS [INTEGER]
			l_list: ARRAYED_LIST [INTEGER]
			l_result: ARRAYED_LIST [INTEGER]
		do
			create l_list.make_from_array (<<1, 2, 3, 4, 5>>)
			create l_ext.make (l_list)
			l_result := l_ext.drop (2)
			assert_integers_equal ("drop_count", 3, l_result.count)
			assert_integers_equal ("drop_first", 3, l_result [1])
		end

feature -- New Feature Tests (Phase 3 Improvements)

	test_min_by
			-- Test finding element with minimum by selector
		local
			l_ext: SIMPLE_LIST_EXTENSIONS [STRING]
			l_list: ARRAYED_LIST [STRING]
		do
			-- Use unique lengths to avoid ambiguity
			create l_list.make_from_array (<<"hello", "hi", "greetings">>)
			create l_ext.make (l_list)
			-- "hi" has shortest length (2)
			if attached l_ext.min_by (agent (s: STRING): INTEGER do Result := s.count end) as l_min then
				assert_strings_equal ("min_by_length", "hi", l_min)
			else
				assert ("min_should_find", False)
			end
		end

	test_max_by
			-- Test finding element with maximum by selector
		local
			l_ext: SIMPLE_LIST_EXTENSIONS [STRING]
			l_list: ARRAYED_LIST [STRING]
		do
			create l_list.make_from_array (<<"hello", "hi", "greetings", "yo">>)
			create l_ext.make (l_list)
			if attached l_ext.max_by (agent (s: STRING): INTEGER do Result := s.count end) as l_max then
				assert_strings_equal ("max_by_length", "greetings", l_max)
			else
				assert ("max_should_find", False)
			end
		end

	test_index_of_first
			-- Test finding index of first matching element
		local
			l_ext: SIMPLE_LIST_EXTENSIONS [INTEGER]
			l_list: ARRAYED_LIST [INTEGER]
			l_cond: SIMPLE_PREDICATE_CONDITION [INTEGER]
		do
			create l_list.make_from_array (<<1, 2, 3, 4, 5, 4, 3>>)
			create l_ext.make (l_list)
			create l_cond.make (agent (i: INTEGER): BOOLEAN do Result := i = 4 end)
			assert_integers_equal ("index_of_first_4", 4, l_ext.index_of_first (l_cond))
		end

	test_index_of_last
			-- Test finding index of last matching element
		local
			l_ext: SIMPLE_LIST_EXTENSIONS [INTEGER]
			l_list: ARRAYED_LIST [INTEGER]
			l_cond: SIMPLE_PREDICATE_CONDITION [INTEGER]
		do
			create l_list.make_from_array (<<1, 2, 3, 4, 5, 4, 3>>)
			create l_ext.make (l_list)
			create l_cond.make (agent (i: INTEGER): BOOLEAN do Result := i = 4 end)
			assert_integers_equal ("index_of_last_4", 6, l_ext.index_of_last (l_cond))
		end

	test_zip
			-- Test combining two lists element-by-element
		local
			l_ext: SIMPLE_LIST_EXTENSIONS [INTEGER]
			l_list1: ARRAYED_LIST [INTEGER]
			l_list2: ARRAYED_LIST [STRING]
			l_result: ARRAYED_LIST [TUPLE [first: INTEGER; second: ANY]]
		do
			create l_list1.make_from_array (<<1, 2, 3>>)
			create l_list2.make_from_array (<<"a", "b", "c">>)
			create l_ext.make (l_list1)
			l_result := l_ext.zip (l_list2)
			assert_integers_equal ("zip_count", 3, l_result.count)
			assert_integers_equal ("zip_first_num", 1, l_result [1].first)
			assert_strings_equal ("zip_first_str", "a", l_result [1].second.out)
		end

	test_chunked
			-- Test splitting into fixed-size sublists
		local
			l_ext: SIMPLE_LIST_EXTENSIONS [INTEGER]
			l_list: ARRAYED_LIST [INTEGER]
			l_result: ARRAYED_LIST [ARRAYED_LIST [INTEGER]]
		do
			create l_list.make_from_array (<<1, 2, 3, 4, 5, 6, 7>>)
			create l_ext.make (l_list)
			l_result := l_ext.chunked (3)
			assert_integers_equal ("chunk_count", 3, l_result.count)
			assert_integers_equal ("chunk1_size", 3, l_result [1].count)
			assert_integers_equal ("chunk2_size", 3, l_result [2].count)
			assert_integers_equal ("chunk3_size", 1, l_result [3].count) -- last is smaller
		end

	test_windowed
			-- Test sliding window sublists
		local
			l_ext: SIMPLE_LIST_EXTENSIONS [INTEGER]
			l_list: ARRAYED_LIST [INTEGER]
			l_result: ARRAYED_LIST [ARRAYED_LIST [INTEGER]]
		do
			create l_list.make_from_array (<<1, 2, 3, 4, 5>>)
			create l_ext.make (l_list)
			l_result := l_ext.windowed (3)
			assert_integers_equal ("window_count", 3, l_result.count) -- [1,2,3], [2,3,4], [3,4,5]
			assert_integers_equal ("window1_first", 1, l_result [1][1])
			assert_integers_equal ("window2_first", 2, l_result [2][1])
			assert_integers_equal ("window3_first", 3, l_result [3][1])
		end

	test_sorted_by
			-- Test sorting by key selector
		local
			l_ext: SIMPLE_SORTABLE_LIST_EXTENSIONS [STRING]
			l_list: ARRAYED_LIST [STRING]
			l_result: ARRAYED_LIST [STRING]
		do
			create l_list.make_from_array (<<"hello", "hi", "greetings", "yo">>)
			create l_ext.make (l_list)
			l_result := l_ext.sorted_by (agent (s: STRING): INTEGER do Result := s.count end)
			assert_strings_equal ("sorted_first", "yo", l_result [1])
			assert_strings_equal ("sorted_last", "greetings", l_result [4])
		end

	test_distinct
			-- Test removing duplicates
		local
			l_ext: SIMPLE_HASHABLE_LIST_EXTENSIONS [INTEGER]
			l_list: ARRAYED_LIST [INTEGER]
			l_result: ARRAYED_LIST [INTEGER]
		do
			create l_list.make_from_array (<<1, 2, 2, 3, 1, 4, 3, 5>>)
			create l_ext.make (l_list)
			l_result := l_ext.distinct
			assert_integers_equal ("distinct_count", 5, l_result.count)
			-- Preserves first occurrence order: 1, 2, 3, 4, 5
			assert_integers_equal ("distinct_first", 1, l_result [1])
			assert_integers_equal ("distinct_last", 5, l_result [5])
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
