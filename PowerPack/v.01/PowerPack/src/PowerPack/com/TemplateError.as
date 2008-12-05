package PowerPack.com
{
	public class TemplateError extends BasicError
	{
		public function TemplateError(message:String="", id:int=0, words:Array=null)
		{
			messages =  
				<errors>
                    <error code="9000"><![CDATA[Template error.]]></error>
                    <error code="9001"><![CDATA[File '{0}' doesn't exist.]]></error>
                </errors>;
	
			super(message, id, words);
			
			severity = FATAL;
		}
		
	}
}