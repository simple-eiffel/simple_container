note
	description: "RAII-style cursor preservation"

class
	SIMPLE_CURSOR_GUARD

create
	make

feature {NONE} -- Initialization

	make (a_cursored: LINEAR [ANY])
			-- Save cursor from `a_cursored`
		require
			cursored_exists: a_cursored /= Void
		do
			target := a_cursored
			if attached {CURSOR_STRUCTURE [ANY]} a_cursored as l_cs then
				saved_cursor := l_cs.cursor
			end
		ensure
			target_set: target = a_cursored
		end

feature -- Restoration

	restore
			-- Restore saved cursor position
		do
			if attached {CURSOR_STRUCTURE [ANY]} target as l_cs then
				if attached saved_cursor as l_cursor and then l_cs.valid_cursor (l_cursor) then
					l_cs.go_to (l_cursor)
				end
			end
		end

feature -- Access

	saved_cursor: detachable CURSOR
			-- The saved cursor

feature {NONE} -- Implementation

	target: LINEAR [ANY]
			-- The container whose cursor we saved

invariant
	target_exists: target /= Void

end
