note
	description: "Disjunction of two conditions"

class
	SIMPLE_OR_CONDITION [G -> detachable separate ANY]

inherit
	SIMPLE_QUERY_CONDITION [G]

create
	make

feature {NONE} -- Initialization

	make (a_left, a_right: SIMPLE_QUERY_CONDITION [G])
			-- Create with two operands
		do
			left := a_left
			right := a_right
		ensure
			left_set: left = a_left
			right_set: right = a_right
		end

feature -- Evaluation

	satisfied_by (a_item: G): BOOLEAN
			-- Does `a_item` satisfy either condition?
		do
			Result := left.satisfied_by (a_item) or right.satisfied_by (a_item)
		end

feature -- Composition

	conjuncted alias "and" (a_other: SIMPLE_QUERY_CONDITION [G]): SIMPLE_AND_CONDITION [G]
			-- Condition satisfied when both self AND `a_other` satisfied
		do
			create Result.make (Current, a_other)
		ensure then
			result_exists: Result /= Void
		end

	disjuncted alias "or" (a_other: SIMPLE_QUERY_CONDITION [G]): SIMPLE_OR_CONDITION [G]
			-- Condition satisfied when self OR `a_other` satisfied
		do
			create Result.make (Current, a_other)
		ensure then
			result_exists: Result /= Void
		end

	negated alias "not": SIMPLE_NOT_CONDITION [G]
			-- Condition satisfied when self NOT satisfied
		do
			create Result.make (Current)
		ensure then
			result_exists: Result /= Void
		end

feature {NONE} -- Implementation

	left: SIMPLE_QUERY_CONDITION [G]
			-- Left operand

	right: SIMPLE_QUERY_CONDITION [G]
			-- Right operand

invariant
	left_exists: left /= Void
	right_exists: right /= Void

end