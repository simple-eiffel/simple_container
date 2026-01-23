note
	description: "Negation of a condition"

class
	SIMPLE_NOT_CONDITION [G -> detachable separate ANY]

inherit
	SIMPLE_QUERY_CONDITION [G]

create
	make

feature {NONE} -- Initialization

	make (a_operand: SIMPLE_QUERY_CONDITION [G])
			-- Create with operand to negate
		do
			operand := a_operand
		ensure
			operand_set: operand = a_operand
		end

feature -- Evaluation

	satisfied_by (a_item: G): BOOLEAN
			-- Does `a_item` NOT satisfy the operand condition?
		do
			Result := not operand.satisfied_by (a_item)
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

	operand: SIMPLE_QUERY_CONDITION [G]
			-- The condition to negate

invariant
	operand_exists: operand /= Void

end