package net.vdombox.powerpack.gen.errorClasses
{
	import net.vdombox.powerpack.BasicError;
	
	public class CompilerWarning extends BasicError
	{
		public function CompilerWarning(message:String="", id:int=0)
		{
			super(message, id);
			severity = WARNING;
		}
		
	}
}