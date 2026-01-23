note
	description: "Condition from a PREDICATE agent"

class
	SIMPLE_PREDICATE_CONDITION [G -> detachable separate ANY]

inherit
	SIMPLE_QUERY_CONDITION [G]

create
	make

feature {NONE} -- Initialization

	make (a_predicate: PREDICATE [G])
			-- Create from predicate agent
		do
			predicate := a_predicate
		ensure
			predicate_set: predicate = a_predicate
		end

feature -- Evaluation

	satisfied_by (a_item: G): BOOLEAN
			-- Does `a_item` satisfy the predicate?
		do
			Result := predicate.item ([a_item])
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

	predicate: PREDICATE [G]
			-- The underlying predicate

invariant
	predicate_exists: predicate /= Void

end