note
	description: "Convert containers to/from strings"

class
	SIMPLE_STRING_CONVERSIONS [G]

feature -- To String

	joined (a_items: ITERABLE [G]; a_separator: READABLE_STRING_GENERAL): STRING_32
			-- Items converted and joined with separator
		require
			items_exists: a_items /= Void
			separator_exists: a_separator /= Void
		do
			create Result.make_empty
			across a_items as ic loop
				if not Result.is_empty then
					Result.append_string_general (a_separator)
				end
				Result.append_string_general (item_to_string (ic))
			end
		ensure
			result_exists: Result /= Void
		end

	joined_with_format (a_items: ITERABLE [G]; a_separator: READABLE_STRING_GENERAL;
			a_formatter: FUNCTION [G, READABLE_STRING_GENERAL]): STRING_32
			-- Items formatted and joined
		require
			items_exists: a_items /= Void
			separator_exists: a_separator /= Void
			formatter_exists: a_formatter /= Void
		do
			create Result.make_empty
			across a_items as ic loop
				if not Result.is_empty then
					Result.append_string_general (a_separator)
				end
				Result.append_string_general (a_formatter.item ([ic]))
			end
		ensure
			result_exists: Result /= Void
		end

feature -- From String

	split_to_list (a_string: READABLE_STRING_GENERAL; a_separator: CHARACTER_32;
			a_converter: FUNCTION [READABLE_STRING_GENERAL, G]): ARRAYED_LIST [G]
			-- Parse string into list using converter
		require
			string_exists: a_string /= Void
			converter_exists: a_converter /= Void
		local
			l_parts: LIST [READABLE_STRING_GENERAL]
		do
			l_parts := a_string.split (a_separator)
			create Result.make (l_parts.count)
			across l_parts as ic loop
				Result.extend (a_converter.item ([ic]))
			end
		ensure
			result_exists: Result /= Void
		end

feature {NONE} -- Implementation

	item_to_string (a_item: G): STRING_32
			-- Default string conversion
		do
			if attached {READABLE_STRING_GENERAL} a_item as l_str then
				Result := l_str.to_string_32
			elseif attached a_item as l_any then
				Result := l_any.out.to_string_32
			else
				Result := "Void"
			end
		end

end
