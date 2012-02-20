package net.vdombox.powerpack.lib.player.gen.errorClasses
{

import net.vdombox.powerpack.lib.player.BasicError;

public class ValidationWarning extends BasicError
{
	public function ValidationWarning( message : String = "", id : int = 0, words : Array = null )
	{
		messages =
				<errors>
					<error code="9000"><![CDATA[Syntax error.]]></error>

					<error code="9001"><![CDATA[Undefined initial graph.]]></error>
					<error code="9002"><![CDATA[Undefined initial state for graph [{0}].]]></error>
					<error code="9003"><![CDATA[Duplicated initial graph [{0}].]]></error>
					<error code="9004"><![CDATA[Duplicated initial state in graph [{0}].]]></error>
					<error code="9005"><![CDATA[Duplicated graph name [{0}].]]></error>
					<error code="9006"><![CDATA[Undefined graph name.]]></error>

					<error code="9100"><![CDATA[Syntax error: invalid graph name.]]></error>

					<error code="9200"><![CDATA[Template error: duplicated state id [{0}].]]></error>
					<error code="9201"><![CDATA[Template error: duplicated transition id [{0}].]]></error>
					<error code="9202"><![CDATA[Template error: multiple transitions between to states [{0}, {1}].]]></error>
					<error code="9203"><![CDATA[Template error: self-loop [{0}] in state [{1}].]]></error>
					<error code="9204"><![CDATA[Template error: invalid transition [{0}].]]></error>
					<error code="9205"><![CDATA[Template error: undefined state id.]]></error>
					<error code="9206"><![CDATA[Template error: undefined transition id.]]></error>
				</errors>;

		super( message, id, words );

		severity = WARNING;
	}

}
}