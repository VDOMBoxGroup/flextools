package net.vdombox.powerpack.lib.player.events
{
	import flash.events.Event;
	
	public class CodeParserEvent extends Event
	{
		public static const EXECUTE_CODE_FRAGMENT : String = "executeCodeFragment";
		
		public var fragmentValue:String;
			
		public function CodeParserEvent (type:String, fragmentValue:String="", bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.fragmentValue = fragmentValue;
		}
		
		override public function clone() : Event
		{
			return new CodeParserEvent( type, fragmentValue,   bubbles,  cancelable );
		}
	}
}