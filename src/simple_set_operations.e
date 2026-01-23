note
	description: "Set operations on collections"

class
	SIMPLE_SET_OPERATIONS [G -> HASHABLE]

feature -- Model

	set_model (a_iterable: ITERABLE [G]): MML_SET [G]
			-- Mathematical model of an iterable as a set
		do
			create Result
			across a_iterable as ic loop
				Result := Result & ic
			end
		end

	result_model (a_set: ARRAYED_SET [G]): MML_SET [G]
			-- Model of result set for postconditions
		do
			create Result
			across a_set as ic loop
				Result := Result & ic
			end
		end

feature -- Set Operations

	union (a_first, a_second: ITERABLE [G]): ARRAYED_SET [G]
			-- All items in `a_first` or `a_second`.
		do
			create Result.make (0)
			across a_first as ic loop
				Result.extend (ic)
			end
			across a_second as ic loop
				Result.extend (ic)
			end
		ensure
			result_is_union: result_model (Result) |=| (set_model (a_first) + set_model (a_second))
		end

	intersection (a_first, a_second: ITERABLE [G]): ARRAYED_SET [G]
			-- Items in both `a_first` and `a_second`.
		local
			l_second_set: ARRAYED_SET [G]
		do
			create l_second_set.make (0)
			across a_second as ic loop
				l_second_set.extend (ic)
			end
			create Result.make (0)
			across a_first as ic loop
				if l_second_set.has (ic) then
					Result.extend (ic)
				end
			end
		ensure
			result_is_intersection: result_model (Result) |=| (set_model (a_first) * set_model (a_second))
		end

	difference (a_first, a_second: ITERABLE [G]): ARRAYED_SET [G]
			-- Items in `a_first` but not in `a_second`.
		local
			l_second_set: ARRAYED_SET [G]
		do
			create l_second_set.make (0)
			across a_second as ic loop
				l_second_set.extend (ic)
			end
			create Result.make (0)
			across a_first as ic loop
				if not l_second_set.has (ic) then
					Result.extend (ic)
				end
			end
		ensure
			result_is_difference: result_model (Result) |=| (set_model (a_first) - set_model (a_second))
		end

	symmetric_difference (a_first, a_second: ITERABLE [G]): ARRAYED_SET [G]
			-- Items in exactly one of `a_first` or `a_second`.
		do
			Result := difference (union (a_first, a_second), intersection (a_first, a_second))
		ensure
			result_is_symmetric_diff: result_model (Result) |=| ((set_model (a_first) + set_model (a_second)) - (set_model (a_first) * set_model (a_second)))
		end

feature -- Subset Relations

	is_subset (a_candidate, a_superset: ITERABLE [G]): BOOLEAN
			-- Is every item in `a_candidate` also in `a_superset`?
		local
			l_super_set: ARRAYED_SET [G]
		do
			create l_super_set.make (0)
			across a_superset as ic loop
				l_super_set.extend (ic)
			end
			Result := True
			across a_candidate as ic until not Result loop
				Result := l_super_set.has (ic)
			end
		ensure
			correct_result: Result = set_model (a_candidate).is_subset_of (set_model (a_superset))
		end

	is_disjoint (a_first, a_second: ITERABLE [G]): BOOLEAN
			-- Do `a_first` and `a_second` have no common items?
		do
			Result := intersection (a_first, a_second).is_empty
		ensure
			correct_result: Result = set_model (a_first).disjoint (set_model (a_second))
		end

end