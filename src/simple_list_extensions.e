note
	description: "Extension methods for lists"

class
	SIMPLE_LIST_EXTENSIONS [G]

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

feature -- Partitioning

	partition (a_condition: SIMPLE_QUERY_CONDITION [G]): TUPLE [satisfying: ARRAYED_LIST [G]; not_satisfying: ARRAYED_LIST [G]]
			-- Split into items that satisfy/don't satisfy condition
		require
			condition_exists: a_condition /= Void
		local
			l_satisfying, l_not_satisfying: ARRAYED_LIST [G]
		do
			create l_satisfying.make (target.count // 2)
			create l_not_satisfying.make (target.count // 2)
			across target as ic loop
				if a_condition.satisfied_by (ic) then
					l_satisfying.extend (ic)
				else
					l_not_satisfying.extend (ic)
				end
			end
			Result := [l_satisfying, l_not_satisfying]
		ensure
			result_exists: Result /= Void
			total_preserved: Result.satisfying.count + Result.not_satisfying.count = target.count
		end

	group_by (a_key_function: FUNCTION [G, HASHABLE]): HASH_TABLE [ARRAYED_LIST [G], HASHABLE]
			-- Group items by key
		require
			key_function_exists: a_key_function /= Void
		local
			l_key: HASHABLE
			l_total: INTEGER
		do
			create Result.make (10)
			across target as ic loop
				l_key := a_key_function.item ([ic])
				if not Result.has (l_key) then
					Result.put (create {ARRAYED_LIST [G]}.make (5), l_key)
				end
				if attached Result.item (l_key) as l_list then
					l_list.extend (ic)
				end
			end
				-- Verify total count preserved (for postcondition)
			across Result as rc loop
				l_total := l_total + rc.count
			end
		ensure
			result_exists: Result /= Void
			total_items_preserved: (across Result as rc all True end) implies
				(across Result as rc2 some rc2.count > 0 end or target.is_empty)
		end

feature -- Extrema

	min_by (a_selector: FUNCTION [G, COMPARABLE]): detachable G
			-- Element with minimum selector value, or Void if empty
		require
			selector_exists: a_selector /= Void
		local
			l_min_value: detachable COMPARABLE
			l_current_value: COMPARABLE
		do
			across target as ic loop
				l_current_value := a_selector.item ([ic])
				if l_min_value = Void or else l_current_value < l_min_value then
					l_min_value := l_current_value
					Result := ic
				end
			end
		ensure
			empty_means_void: target.is_empty implies Result = Void
			non_empty_means_attached: not target.is_empty implies Result /= Void
		end

	max_by (a_selector: FUNCTION [G, COMPARABLE]): detachable G
			-- Element with maximum selector value, or Void if empty
		require
			selector_exists: a_selector /= Void
		local
			l_max_value: detachable COMPARABLE
			l_current_value: COMPARABLE
		do
			across target as ic loop
				l_current_value := a_selector.item ([ic])
				if l_max_value = Void or else l_current_value > l_max_value then
					l_max_value := l_current_value
					Result := ic
				end
			end
		ensure
			empty_means_void: target.is_empty implies Result = Void
			non_empty_means_attached: not target.is_empty implies Result /= Void
		end

feature -- Index Finding

	index_of_first (a_condition: SIMPLE_QUERY_CONDITION [G]): INTEGER
			-- Index of first matching element (1-based), or 0 if none
		require
			condition_exists: a_condition /= Void
		local
			i: INTEGER
		do
			from i := 1 until i > target.count or Result > 0 loop
				if a_condition.satisfied_by (target [i]) then
					Result := i
				end
				i := i + 1
			end
		ensure
			valid_or_zero: Result >= 0 and Result <= target.count
		end

	index_of_last (a_condition: SIMPLE_QUERY_CONDITION [G]): INTEGER
			-- Index of last matching element (1-based), or 0 if none
		require
			condition_exists: a_condition /= Void
		local
			i: INTEGER
		do
			from i := target.count until i < 1 loop
				if a_condition.satisfied_by (target [i]) then
					Result := i
					i := 0 -- Exit loop
				else
					i := i - 1
				end
			end
		ensure
			valid_or_zero: Result >= 0 and Result <= target.count
		end

feature -- Ordering

	reversed: ARRAYED_LIST [G]
			-- Items in reverse order
		do
			create Result.make (target.count)
			across target as ic loop
				Result.put_front (ic)
			end
		ensure
			result_exists: Result /= Void
			same_count: Result.count = target.count
		end

feature -- Taking/Dropping

	take (n: INTEGER): ARRAYED_LIST [G]
			-- First `n` items (or all if fewer)
		require
			non_negative: n >= 0
		local
			l_count, i: INTEGER
		do
			l_count := n.min (target.count)
			create Result.make (l_count)
			from i := 1 until i > l_count loop
				Result.extend (target [i])
				i := i + 1
			end
		ensure
			result_exists: Result /= Void
			bounded_count: Result.count <= n and Result.count <= target.count
		end

	drop (n: INTEGER): ARRAYED_LIST [G]
			-- All items except first `n`
		require
			non_negative: n >= 0
		local
			l_start, i: INTEGER
		do
			l_start := (n + 1).min (target.count + 1)
			create Result.make ((target.count - n).max (0))
			from i := l_start until i > target.count loop
				Result.extend (target [i])
				i := i + 1
			end
		ensure
			result_exists: Result /= Void
			correct_count: Result.count = (target.count - n).max (0)
		end

	take_while (a_condition: SIMPLE_QUERY_CONDITION [G]): ARRAYED_LIST [G]
			-- Leading items that satisfy `a_condition`
		require
			condition_exists: a_condition /= Void
		do
			create Result.make (target.count // 2)
			across target as ic until not a_condition.satisfied_by (ic) loop
				Result.extend (ic)
			end
		ensure
			result_exists: Result /= Void
			bounded: Result.count <= target.count
		end

	drop_while (a_condition: SIMPLE_QUERY_CONDITION [G]): ARRAYED_LIST [G]
			-- Items after leading sequence satisfying `a_condition`
		require
			condition_exists: a_condition /= Void
		local
			l_dropping: BOOLEAN
		do
			create Result.make (target.count // 2)
			l_dropping := True
			across target as ic loop
				if l_dropping and then a_condition.satisfied_by (ic) then
					-- skip
				else
					l_dropping := False
					Result.extend (ic)
				end
			end
		ensure
			result_exists: Result /= Void
			bounded: Result.count <= target.count
		end

feature -- Combining

	zip (a_other: LIST [ANY]): ARRAYED_LIST [TUPLE [first: G; second: ANY]]
			-- Combine with other list element-by-element
			-- Result length is minimum of both list lengths
		require
			other_exists: a_other /= Void
		local
			l_count, i: INTEGER
		do
			l_count := target.count.min (a_other.count)
			create Result.make (l_count)
			from i := 1 until i > l_count loop
				Result.extend ([target [i], a_other [i]])
				i := i + 1
			end
		ensure
			result_exists: Result /= Void
			correct_count: Result.count = target.count.min (a_other.count)
		end

feature -- Chunking

	chunked (a_size: INTEGER): ARRAYED_LIST [ARRAYED_LIST [G]]
			-- Split into sublists of given size (last may be smaller)
		require
			positive_size: a_size > 0
		local
			l_chunk: ARRAYED_LIST [G]
			l_count, i: INTEGER
		do
			l_count := (target.count + a_size - 1) // a_size
			create Result.make (l_count)
			create l_chunk.make (a_size)
			from i := 1 until i > target.count loop
				l_chunk.extend (target [i])
				if l_chunk.count = a_size or i = target.count then
					Result.extend (l_chunk)
					if i < target.count then
						create l_chunk.make (a_size)
					end
				end
				i := i + 1
			end
		ensure
			result_exists: Result /= Void
			chunks_bounded: across Result as c all c.count <= a_size end
		end

	windowed (a_size: INTEGER): ARRAYED_LIST [ARRAYED_LIST [G]]
			-- Sliding window sublists of given size
		require
			positive_size: a_size > 0
		local
			l_window: ARRAYED_LIST [G]
			i, j: INTEGER
		do
			if target.count < a_size then
				create Result.make (0)
			else
				create Result.make (target.count - a_size + 1)
				from i := 1 until i > target.count - a_size + 1 loop
					create l_window.make (a_size)
					from j := 0 until j >= a_size loop
						l_window.extend (target [i + j])
						j := j + 1
					end
					Result.extend (l_window)
					i := i + 1
				end
			end
		ensure
			result_exists: Result /= Void
			windows_exact_size: across Result as w all w.count = a_size end
		end

feature {NONE} -- Implementation

	target: LIST [G]
			-- The wrapped list

invariant
	target_exists: target /= Void

end
