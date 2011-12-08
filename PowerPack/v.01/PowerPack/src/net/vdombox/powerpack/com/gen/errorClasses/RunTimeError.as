package net.vdombox.powerpack.com.gen.errorClasses
{
	import net.vdombox.powerpack.com.BasicError;
	
	public class RunTimeError extends BasicError
	{
		public function RunTimeError(message:String="", id:int=0, words:Array=null)
		{
			messages =  
				<errors>
                    <error code="9000"><![CDATA[Syntax error.]]></error>                    
                    <error code="9001"><![CDATA[Syntax error: invalid variable definition]]></error>
                    <error code="9002"><![CDATA[Syntax error: {0} is unexpected.]]></error>
                    //<error code="9003"><![CDATA[Syntax error: closing brace {0} is unexpected.]]></error>
                    //<error code="9004"><![CDATA[Syntax error: expecting {0} before {1}.]]></error>
                    <error code="9005"><![CDATA[Syntax error: expecting {0} before end of command.]]></error>
                    //<error code="9006"><![CDATA[Syntax error: input ended before reaching the closing quotation mark for a string literal.]]></error>

                    <error code="9007"><![CDATA[Incorrect number of arguments. Expected {0}.]]></error>                    
                    <error code="9008"><![CDATA[Variable {0} is not defined.]]></error>
                    //<error code="9009"><![CDATA[{0} is not a function.]]></error>
                    <error code="9010"><![CDATA[The value specified for argument {0} is invalid.]]></error>
                    <error code="9011"><![CDATA[One of the parameters is invalid.]]></error>
                    <error code="9012"><![CDATA[Parameter {0} is of the incorrect type. Should be type {1}.]]></error>
                    <error code="9013"><![CDATA[The supplied index is out of bounds.]]></error>
                    //<error code="9014"><![CDATA[Parameter {0} must be non-null.]]></error>
                    //<error code="9015"><![CDATA[Parameter {0} must be one of the accepted values.]]></error>
                    //<error code="9016"><![CDATA[Parameter {0} must be a non-negative number; got {1}.]]></error>
                </errors>;

			super(message, id, words);
			
			severity = FATAL;
		}		
	}
}