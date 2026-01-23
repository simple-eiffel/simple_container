note
	description: "Sorting extensions for lists"

class
	SIMPLE_SORTABLE_LIST_EXTENSIONS [G -> detachable separate ANY]

create
	make

feature {NONE} -- Initialization

	make (a_list: LIST [G])
			-- Create extensions wrapper for `a_list`
		do
			target := a_list
		ensure
			target_set: target = a_list
			model_matches: model.count = a_list.count
		end

feature -- Model

	model: MML_SEQUENCE [G]
			-- Mathematical model of target list contents
		do
			create Result
			across target as ic loop
				Result := Result & ic
			end
		ensure
			count_matches: Result.count = target.count
		end

	list_model (a_list: LIST [G]): MML_SEQUENCE [G]
			-- Model of a result list for postconditions
		do
			create Result
			across a_list as ic loop
				Result := Result & ic
			end
		end

feature -- Sorting

	sorted_by (a_key: FUNCTION [G, COMPARABLE]): ARRAYED_LIST [G]
			-- Elements sorted by key selector (ascending)
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
	model_consistent: model.count = target.count

end