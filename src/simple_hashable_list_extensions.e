note
	description: "Extensions for lists of hashable elements"

class
	SIMPLE_HASHABLE_LIST_EXTENSIONS [G -> HASHABLE]

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
	model_consistent: model.count = target.count

end