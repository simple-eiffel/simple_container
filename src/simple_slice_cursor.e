note
	description: "Cursor for iterating over a slice"

class
	SIMPLE_SLICE_CURSOR [G -> detachable separate ANY]

inherit
	ITERATION_CURSOR [G]

create
	make

feature {NONE} -- Initialization

	make (a_slice: SIMPLE_SLICE [G])
			-- Create cursor for `a_slice`
		do
			slice := a_slice
			position := 1
		ensure
			slice_set: slice = a_slice
			position_at_start: position = 1
		end

feature -- Access

	item: G
			-- Current item
		require else
			not_after: not after
		do
			Result := slice.item (position)
		end

feature -- Status

	after: BOOLEAN
			-- Is cursor past last item?
		do
			Result := position > slice.count
		end

feature -- Cursor movement

	forth
			-- Move to next item
		require else
			not_after: not after
		do
			position := position + 1
		ensure then
			position_advanced: position = old position + 1
		end

feature {NONE} -- Implementation

	slice: SIMPLE_SLICE [G]
			-- The slice being iterated

	position: INTEGER
			-- Current position within slice

invariant
	slice_exists: slice /= Void
	position_positive: position >= 1

end