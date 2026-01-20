note
	description: "Array/list slice with lazy evaluation"

class
	SIMPLE_SLICE [G]

inherit
	ITERABLE [G]

create
	make, make_from_end

feature {NONE} -- Initialization

	make (a_source: READABLE_INDEXABLE [G]; a_start, a_end: INTEGER)
			-- Create slice from `a_start` to `a_end` (inclusive)
		require
			source_exists: a_source /= Void
			valid_start: a_start >= a_source.lower
			valid_end: a_end <= a_source.upper
			valid_range: a_start <= a_end + 1
		do
			source := a_source
			start_index := a_start
			end_index := a_end
		ensure
			source_set: source = a_source
			start_set: start_index = a_start
			end_set: end_index = a_end
		end

	make_from_end (a_source: READABLE_INDEXABLE [G]; a_start_from_end, a_count: INTEGER)
			-- Create slice of `a_count` items starting `a_start_from_end` from end
		require
			source_exists: a_source /= Void
			non_negative_offset: a_start_from_end >= 0
			positive_count: a_count > 0
			valid_range: a_start_from_end + a_count <= (a_source.upper - a_source.lower + 1)
		do
			source := a_source
			end_index := a_source.upper - a_start_from_end
			start_index := end_index - a_count + 1
		ensure
			source_set: source = a_source
		end

feature -- Access

	item alias "[]" (i: INTEGER): G
			-- Item at position `i` within slice (1-based)
		require
			valid_index: valid_index (i)
		do
			Result := source [start_index + i - 1]
		end

	first: G
			-- First item
		require
			not_empty: not is_empty
		do
			Result := source [start_index]
		end

	last: G
			-- Last item
		require
			not_empty: not is_empty
		do
			Result := source [end_index]
		end

feature -- Measurement

	count: INTEGER
			-- Number of items in slice
		do
			Result := (end_index - start_index + 1).max (0)
		ensure
			non_negative: Result >= 0
		end

	is_empty: BOOLEAN
			-- Is slice empty?
		do
			Result := count = 0
		ensure
			definition: Result = (count = 0)
		end

feature -- Status Query

	valid_index (i: INTEGER): BOOLEAN
			-- Is `i` valid within slice?
		do
			Result := i >= 1 and i <= count
		end

feature -- Iteration

	new_cursor: SIMPLE_SLICE_CURSOR [G]
			-- Fresh cursor for iteration
		do
			create Result.make (Current)
		end

feature -- Conversion

	to_array: ARRAY [G]
			-- Copy to array
		local
			i: INTEGER
		do
			if is_empty then
				create Result.make_empty
			else
				create Result.make_filled (first, 1, count)
				from i := 1 until i > count loop
					Result [i] := item (i)
					i := i + 1
				end
			end
		ensure
			result_exists: Result /= Void
			same_count: Result.count = count
		end

	to_list: ARRAYED_LIST [G]
			-- Copy to list
		do
			create Result.make (count)
			across Current as ic loop
				Result.extend (ic)
			end
		ensure
			result_exists: Result /= Void
			same_count: Result.count = count
		end

feature -- Sub-slicing

	sub_slice (a_start, a_end: INTEGER): SIMPLE_SLICE [G]
			-- Sub-slice from `a_start` to `a_end`
		require
			valid_start: a_start >= 1
			valid_end: a_end <= count
			valid_range: a_start <= a_end + 1
		do
			create Result.make (source, start_index + a_start - 1, start_index + a_end - 1)
		ensure
			result_exists: Result /= Void
			correct_count: Result.count = a_end - a_start + 1
		end

feature {SIMPLE_SLICE_CURSOR} -- Implementation Access

	source: READABLE_INDEXABLE [G]
			-- Source container

	start_index: INTEGER
			-- Start index in source

	end_index: INTEGER
			-- End index in source

invariant
	source_exists: source /= Void
	count_consistent: count = (end_index - start_index + 1).max (0)

end
