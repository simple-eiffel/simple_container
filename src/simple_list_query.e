note
	description: "Query operations on lists with cursor safety"

class
	SIMPLE_LIST_QUERY [G]

create
	make

feature {NONE} -- Initialization

	make (a_list: LIST [G])
			-- Create query wrapper for `a_list`
		require
			list_exists: a_list /= Void
		do
			target := a_list
		ensure
			target_set: target = a_list
		end

feature -- Queries (Cursor-Safe via across)

	filtered (a_condition: SIMPLE_QUERY_CONDITION [G]): ARRAYED_LIST [G]
			-- Items satisfying `a_condition`
		require
			condition_exists: a_condition /= Void
		do
			create Result.make (target.count // 2)
			across target as ic loop
				if a_condition.satisfied_by (ic) then
					Result.extend (ic)
				end
			end
		ensure
			result_exists: Result /= Void
			bounded: Result.count <= target.count
		end

	first_satisfying (a_condition: SIMPLE_QUERY_CONDITION [G]): detachable G
			-- First item satisfying `a_condition`, or Void
		require
			condition_exists: a_condition /= Void
		local
			l_found: BOOLEAN
		do
			across target as ic until l_found loop
				if a_condition.satisfied_by (ic) then
					Result := ic
					l_found := True
				end
			end
		end

	all_satisfy (a_condition: SIMPLE_QUERY_CONDITION [G]): BOOLEAN
			-- Do all items satisfy `a_condition`?
		require
			condition_exists: a_condition /= Void
		do
			Result := True
			across target as ic until not Result loop
				Result := a_condition.satisfied_by (ic)
			end
		end

	any_satisfies (a_condition: SIMPLE_QUERY_CONDITION [G]): BOOLEAN
			-- Does any item satisfy `a_condition`?
		require
			condition_exists: a_condition /= Void
		do
			across target as ic until Result loop
				Result := a_condition.satisfied_by (ic)
			end
		end

	count_satisfying (a_condition: SIMPLE_QUERY_CONDITION [G]): INTEGER
			-- Number of items satisfying `a_condition`
		require
			condition_exists: a_condition /= Void
		do
			across target as ic loop
				if a_condition.satisfied_by (ic) then
					Result := Result + 1
				end
			end
		ensure
			non_negative: Result >= 0
			bounded: Result <= target.count
		end

feature -- Mapping (Cursor-Safe via across)

	mapped (a_function: FUNCTION [G, ANY]): ARRAYED_LIST [ANY]
			-- Result of applying `a_function` to each item
		require
			function_exists: a_function /= Void
		do
			create Result.make (target.count)
			across target as ic loop
				Result.extend (a_function.item ([ic]))
			end
		ensure
			result_exists: Result /= Void
			same_count: Result.count = target.count
		end

feature -- Reduction (Cursor-Safe via across)

	folded (a_initial: ANY; a_combiner: FUNCTION [ANY, G, ANY]): detachable ANY
			-- Result of combining all items starting with `a_initial`
		require
			combiner_exists: a_combiner /= Void
		do
			Result := a_initial
			across target as ic loop
				Result := a_combiner.item ([Result, ic])
			end
		end

feature {NONE} -- Implementation

	target: LIST [G]
			-- The wrapped list

invariant
	target_exists: target /= Void

end
