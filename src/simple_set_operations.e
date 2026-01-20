note
	description: "Set operations on collections"

class
	SIMPLE_SET_OPERATIONS [G -> HASHABLE]

feature -- Set Operations

	union (a_first, a_second: ITERABLE [G]): ARRAYED_SET [G]
			-- All items in `a_first` or `a_second`
		require
			first_exists: a_first /= Void
			second_exists: a_second /= Void
		do
			create Result.make (0)
			across a_first as ic loop
				Result.extend (ic)
			end
			across a_second as ic loop
				Result.extend (ic)
			end
		ensure
			result_exists: Result /= Void
		end

	intersection (a_first, a_second: ITERABLE [G]): ARRAYED_SET [G]
			-- Items in both `a_first` and `a_second`
		require
			first_exists: a_first /= Void
			second_exists: a_second /= Void
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
			result_exists: Result /= Void
		end

	difference (a_first, a_second: ITERABLE [G]): ARRAYED_SET [G]
			-- Items in `a_first` but not in `a_second`
		require
			first_exists: a_first /= Void
			second_exists: a_second /= Void
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
			result_exists: Result /= Void
		end

	symmetric_difference (a_first, a_second: ITERABLE [G]): ARRAYED_SET [G]
			-- Items in exactly one of `a_first` or `a_second`
		require
			first_exists: a_first /= Void
			second_exists: a_second /= Void
		do
			Result := difference (union (a_first, a_second), intersection (a_first, a_second))
		ensure
			result_exists: Result /= Void
		end

feature -- Subset Relations

	is_subset (a_candidate, a_superset: ITERABLE [G]): BOOLEAN
			-- Is every item in `a_candidate` also in `a_superset`?
		require
			candidate_exists: a_candidate /= Void
			superset_exists: a_superset /= Void
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
		end

	is_disjoint (a_first, a_second: ITERABLE [G]): BOOLEAN
			-- Do `a_first` and `a_second` have no common items?
		require
			first_exists: a_first /= Void
			second_exists: a_second /= Void
		do
			Result := intersection (a_first, a_second).is_empty
		end

end
