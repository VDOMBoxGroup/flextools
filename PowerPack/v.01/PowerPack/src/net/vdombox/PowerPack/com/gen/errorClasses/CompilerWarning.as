package net.vdombox.powerpack.com.gen.errorClasses
{
	import net.vdombox.powerpack.com.BasicError;
	
	public class CompilerWarning extends BasicError
	{
		public function CompilerWarning(message:String="", id:int=0)
		{
			super(message, id);
			severity = WARNING;
		}
		
	}
}