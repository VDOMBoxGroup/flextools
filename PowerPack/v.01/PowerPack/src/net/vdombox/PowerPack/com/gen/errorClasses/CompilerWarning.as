package net.vdombox.PowerPack.com.gen.errorClasses
{
	import net.vdombox.PowerPack.com.BasicError;
	
	public class CompilerWarning extends BasicError
	{
		public function CompilerWarning(message:String="", id:int=0)
		{
			super(message, id);
			severity = WARNING;
		}
		
	}
}