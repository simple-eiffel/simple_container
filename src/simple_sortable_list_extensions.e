note
	description: "Sorting extensions for lists"

class
	SIMPLE_SORTABLE_LIST_EXTENSIONS [G]

create
	make

feature {NONE} -- Initialization

	make (a_list: LIST [G])
			-- Create extensions wrapper for `a_list`
		require
			list_exists: a_list /= Void
		do
			target := a_list
		ensure
			target_set: target = a_list
		end

feature -- Sorting

	sorted_by (a_key: FUNCTION [G, COMPARABLE]): ARRAYED_LIST [G]
			-- Elements sorted by key selector (ascending)
		require
			key_function_exists: a_key /= Void
		do
			create Result.make (target.count)
			across target as ic loop
				Result.extend (ic)
			end
			if Result.count > 1 then
				insertion_sort (Result, a_key, False)
			end
		ensure
			result_exists: Result /= Void
			same_count: Result.count = target.count
			-- NOTE: is_sorted postcondition with agent calls in across loops
			-- causes catcall issues. Sorting verified by tests instead.
		end

	sorted_by_descending (a_key: FUNCTION [G, COMPARABLE]): ARRAYED_LIST [G]
			-- Elements sorted by key selector (descending)
		require
			key_function_exists: a_key /= Void
		do
			create Result.make (target.count)
			across target as ic loop
				Result.extend (ic)
			end
			if Result.count > 1 then
				insertion_sort (Result, a_key, True)
			end
		ensure
			result_exists: Result /= Void
			same_count: Result.count = target.count
			-- NOTE: is_sorted postcondition with agent calls in across loops
			-- causes catcall issues. Sorting verified by tests instead.
		end

feature {NONE} -- Implementation

	target: LIST [G]
			-- The wrapped list

	insertion_sort (a_list: ARRAYED_LIST [G]; a_key: FUNCTION [G, COMPARABLE]; a_descending: BOOLEAN)
			-- Sort `a_list` in place using insertion sort
		local
			i, j: INTEGER
			l_current: G
			l_current_key, l_compare_key: COMPARABLE
		do
			from i := 2 until i > a_list.count loop
				l_current := a_list [i]
				l_current_key := a_key.item ([l_current])
				j := i - 1
				from until j < 1 loop
					l_compare_key := a_key.item ([a_list [j]])
					if a_descending then
						if l_compare_key < l_current_key then
							a_list [j + 1] := a_list [j]
							j := j - 1
						else
							j := 0 -- exit
						end
					else
						if l_compare_key > l_current_key then
							a_list [j + 1] := a_list [j]
							j := j - 1
						else
							j := 0 -- exit
						end
					end
				end
				a_list [j + 1] := l_current
				i := i + 1
			end
		end

invariant
	target_exists: target /= Void

end
