package PowerPack.com.gen
{
import PowerPack.com.BasicError;

public class ValidationError extends BasicError
{
			
	public function ValidationError(message:String="", id:int=0, words:Array=null)
	{
		messages =  
			<errors>
                <error code="9000"><![CDATA[Syntax error.]]></error>

                <error code="9001"><![CDATA[Undefined initial graph.]]></error>                    
                <error code="9002"><![CDATA[Undefined initial state for graph [{0}].]]></error>                    
                <error code="9003"><![CDATA[Duplicated initial graph [{0}].]]></error>                    
                <error code="9004"><![CDATA[Duplicated initial state in graph [{0}].]]></error>                    
                <error code="9005"><![CDATA[Duplicated graph name [{0}].]]></error>                    
                <error code="9006"><![CDATA[Undefined graph name [{0}].]]></error>                    

                <error code="9100"><![CDATA[Syntax error: invalid graph name.]]></error>
            </errors>;
                
		super(message, id, words);
		
		severity = FATAL;
	}
	
}
}