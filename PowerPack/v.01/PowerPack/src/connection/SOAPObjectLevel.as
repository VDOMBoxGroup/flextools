package connection
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class SOAPObjectLevel extends EventDispatcher
	{
		public function SOAPObjectLevel(target:IEventDispatcher=null)
		{
			super(target);
		}
	}
}