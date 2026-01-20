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
		local
			l_sorter: SIMPLE_SORTER [G]
		do
			create Result.make (target.count)
			across target as ic loop
				Result.extend (ic)
			end
			if Result.count > 1 then
				create l_sorter.make
				l_sorter.sort_by (Result, a_key)
			end
		ensure
			result_exists: Result /= Void
			same_count: Result.count = target.count
		end

	sorted_by_descending (a_key: FUNCTION [G, COMPARABLE]): ARRAYED_LIST [G]
			-- Elements sorted by key selector (descending)
		require
			key_function_exists: a_key /= Void
		local
			l_sorter: SIMPLE_SORTER [G]
		do
			create Result.make (target.count)
			across target as ic loop
				Result.extend (ic)
			end
			if Result.count > 1 then
				create l_sorter.make
				l_sorter.sort_by_descending (Result, a_key)
			end
		ensure
			result_exists: Result /= Void
			same_count: Result.count = target.count
		end

feature {NONE} -- Implementation

	target: LIST [G]
			-- The wrapped list

invariant
	target_exists: target /= Void

end
