note
	description: "Query operations on lists with cursor safety"

class
	SIMPLE_LIST_QUERY [G -> detachable separate ANY]

create
	make

feature {NONE} -- Initialization

	make (a_list: LIST [G])
			-- Create query wrapper for `a_list`.
		do
			target := a_list
		ensure
			target_set: target = a_list
		end

feature -- Queries (Cursor-Safe via across)

	filtered (a_condition: SIMPLE_QUERY_CONDITION [G]): ARRAYED_LIST [G]
			-- Items satisfying `a_condition`.
		do
			create Result.make (target.count // 2)
			across target as ic loop
				if a_condition.satisfied_by (ic) then
					Result.extend (ic)
				end
			end
		ensure
			bounded: Result.count <= target.count
			result_subset: result_model (Result).range <= model.range
		end

	first_satisfying (a_condition: SIMPLE_QUERY_CONDITION [G]): detachable G
			-- First item satisfying `a_condition`, or Void.
		local
			l_found: BOOLEAN
		do
			across target as ic until l_found loop
				if a_condition.satisfied_by (ic) then
					Result := ic
					l_found := True
				end
			end
		ensure
			result_in_model: Result /= Void implies model.range.has (Result)
			result_satisfies: attached Result as r implies a_condition.satisfied_by (r)
		end

	all_satisfy (a_condition: SIMPLE_QUERY_CONDITION [G]): BOOLEAN
			-- Do all items satisfy `a_condition`?
		do
			Result := True
			across target as ic until not Result loop
				Result := a_condition.satisfied_by (ic)
			end
		ensure
			empty_is_true: target.is_empty implies Result
		end

	any_satisfies (a_condition: SIMPLE_QUERY_CONDITION [G]): BOOLEAN
			-- Does any item satisfy `a_condition`?
		do
			across target as ic until Result loop
				Result := a_condition.satisfied_by (ic)
			end
		ensure
			empty_is_false: target.is_empty implies not Result
		end

	count_satisfying (a_condition: SIMPLE_QUERY_CONDITION [G]): INTEGER
			-- Number of items satisfying `a_condition`.
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
			-- Result of applying `a_function` to each item.
		do
			create Result.make (target.count)
			across target as ic loop
				Result.extend (a_function.item ([ic]))
			end
		ensure
			same_count: Result.count = target.count
			model_same_count: Result.count = model.count
		end

feature -- Reduction (Cursor-Safe via across)

	folded (a_initial: ANY; a_combiner: FUNCTION [ANY, G, ANY]): detachable ANY
			-- Result of combining all items starting with `a_initial`.
		do
			Result := a_initial
			across target as ic loop
				Result := a_combiner.item ([Result, ic])
			end
		end

feature -- Model

	model: MML_SEQUENCE [G]
			-- Mathematical model of target list contents.
		do
			create Result
			across target as ic loop
				Result := Result & ic
			end
		end

	result_model (a_list: LIST [G]): MML_SEQUENCE [G]
			-- Model of a result list for postconditions.
		do
			create Result
			across a_list as ic loop
				Result := Result & ic
			end
		end

feature {NONE} -- Implementation

	target: LIST [G]
			-- The wrapped list

invariant
	target_attached: target /= Void
	model_consistent: model.count = target.count

end