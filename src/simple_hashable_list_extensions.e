note
	description: "Extensions for lists of hashable elements"

class
	SIMPLE_HASHABLE_LIST_EXTENSIONS [G -> HASHABLE]

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

feature -- Distinct

	distinct: ARRAYED_LIST [G]
			-- Elements with duplicates removed (preserves first occurrence order)
		local
			l_seen: ARRAYED_SET [G]
		do
			create l_seen.make (target.count)
			create Result.make (target.count)
			across target as ic loop
				if not l_seen.has (ic) then
					l_seen.extend (ic)
					Result.extend (ic)
				end
			end
		ensure
			result_exists: Result /= Void
			no_larger: Result.count <= target.count
		end

	distinct_by (a_key: FUNCTION [G, HASHABLE]): ARRAYED_LIST [G]
			-- Elements with duplicates by key removed (preserves first occurrence)
		require
			key_function_exists: a_key /= Void
		local
			l_seen: ARRAYED_SET [HASHABLE]
			l_key: HASHABLE
		do
			create l_seen.make (target.count)
			create Result.make (target.count)
			across target as ic loop
				l_key := a_key.item ([ic])
				if not l_seen.has (l_key) then
					l_seen.extend (l_key)
					Result.extend (ic)
				end
			end
		ensure
			result_exists: Result /= Void
			no_larger: Result.count <= target.count
		end

feature {NONE} -- Implementation

	target: LIST [G]
			-- The wrapped list

invariant
	target_exists: target /= Void

end
