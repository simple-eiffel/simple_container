note
	description: "Test application for SIMPLE_CONTAINER"

class
	TEST_APP

create
	make

feature {NONE} -- Initialization

	make
			-- Run the tests.
		do
			print ("Running SIMPLE_CONTAINER tests...%N%N")
			passed := 0
			failed := 0

			run_condition_tests
			run_list_query_tests
			run_slice_tests
			run_set_operation_tests
			run_string_conversion_tests
			run_list_extension_tests
			run_new_feature_tests
			run_adversarial_tests

			print ("%N========================%N")
			print ("Results: " + passed.out + " passed, " + failed.out + " failed%N")

			if failed > 0 then
				print ("TESTS FAILED%N")
			else
				print ("ALL TESTS PASSED%N")
			end
		end

feature {NONE} -- Test Runners

	run_condition_tests
		do
			create lib_tests
			run_test (agent lib_tests.test_predicate_condition, "test_predicate_condition")
			run_test (agent lib_tests.test_and_condition, "test_and_condition")
			run_test (agent lib_tests.test_or_condition, "test_or_condition")
			run_test (agent lib_tests.test_not_condition, "test_not_condition")
		end

	run_list_query_tests
		do
			run_test (agent lib_tests.test_filtered, "test_filtered")
			run_test (agent lib_tests.test_first_satisfying, "test_first_satisfying")
			run_test (agent lib_tests.test_all_satisfy, "test_all_satisfy")
			run_test (agent lib_tests.test_any_satisfies, "test_any_satisfies")
			run_test (agent lib_tests.test_count_satisfying, "test_count_satisfying")
		end

	run_slice_tests
		do
			run_test (agent lib_tests.test_slice_make, "test_slice_make")
			run_test (agent lib_tests.test_slice_item, "test_slice_item")
			run_test (agent lib_tests.test_slice_iteration, "test_slice_iteration")
			run_test (agent lib_tests.test_slice_to_array, "test_slice_to_array")
		end

	run_set_operation_tests
		do
			run_test (agent lib_tests.test_union, "test_union")
			run_test (agent lib_tests.test_intersection, "test_intersection")
			run_test (agent lib_tests.test_difference, "test_difference")
			run_test (agent lib_tests.test_is_subset, "test_is_subset")
		end

	run_string_conversion_tests
		do
			run_test (agent lib_tests.test_joined, "test_joined")
		end

	run_list_extension_tests
		do
			run_test (agent lib_tests.test_partition, "test_partition")
			run_test (agent lib_tests.test_reversed, "test_reversed")
			run_test (agent lib_tests.test_take, "test_take")
			run_test (agent lib_tests.test_drop, "test_drop")
		end

	run_new_feature_tests
		do
			run_test (agent lib_tests.test_min_by, "test_min_by")
			run_test (agent lib_tests.test_max_by, "test_max_by")
			run_test (agent lib_tests.test_index_of_first, "test_index_of_first")
			run_test (agent lib_tests.test_index_of_last, "test_index_of_last")
			run_test (agent lib_tests.test_zip, "test_zip")
			run_test (agent lib_tests.test_chunked, "test_chunked")
			run_test (agent lib_tests.test_windowed, "test_windowed")
			run_test (agent lib_tests.test_sorted_by, "test_sorted_by")
			run_test (agent lib_tests.test_distinct, "test_distinct")
		end

	run_adversarial_tests
		do
			create adv_tests
			run_test (agent adv_tests.test_empty_list_operations, "test_empty_list_operations")
			run_test (agent adv_tests.test_single_element_list, "test_single_element_list")
			run_test (agent adv_tests.test_slice_boundaries, "test_slice_boundaries")
			run_test (agent adv_tests.test_set_operations_empty, "test_set_operations_empty")
			run_test (agent adv_tests.test_string_conversions_edge_cases, "test_string_conversions_edge_cases")
			run_test (agent adv_tests.test_condition_composition_complex, "test_condition_composition_complex")
			run_test (agent adv_tests.test_take_drop_boundaries, "test_take_drop_boundaries")
			-- Phase 3 adversarial tests
			run_test (agent adv_tests.test_min_max_empty_list, "test_min_max_empty_list")
			run_test (agent adv_tests.test_min_max_single_element, "test_min_max_single_element")
			run_test (agent adv_tests.test_min_max_all_equal, "test_min_max_all_equal")
			run_test (agent adv_tests.test_zip_different_lengths, "test_zip_different_lengths")
			run_test (agent adv_tests.test_zip_empty_second_list, "test_zip_empty_second_list")
			run_test (agent adv_tests.test_chunked_larger_than_list, "test_chunked_larger_than_list")
			run_test (agent adv_tests.test_chunked_exact_division, "test_chunked_exact_division")
			run_test (agent adv_tests.test_windowed_small_list, "test_windowed_small_list")
			run_test (agent adv_tests.test_sorted_by_empty, "test_sorted_by_empty")
			run_test (agent adv_tests.test_sorted_by_single, "test_sorted_by_single")
			run_test (agent adv_tests.test_distinct_all_duplicates, "test_distinct_all_duplicates")
			run_test (agent adv_tests.test_distinct_preserves_order, "test_distinct_preserves_order")
			run_test (agent adv_tests.test_index_of_not_found, "test_index_of_not_found")
		end

feature {NONE} -- Implementation

	lib_tests: LIB_TESTS

	adv_tests: ADVERSARIAL_TESTS

	passed: INTEGER
	failed: INTEGER

	run_test (a_test: PROCEDURE; a_name: STRING)
			-- Run a single test and update counters.
		local
			l_retried: BOOLEAN
		do
			if not l_retried then
				a_test.call (Void)
				print ("  PASS: " + a_name + "%N")
				passed := passed + 1
			end
		rescue
			print ("  FAIL: " + a_name + "%N")
			failed := failed + 1
			l_retried := True
			retry
		end

end
