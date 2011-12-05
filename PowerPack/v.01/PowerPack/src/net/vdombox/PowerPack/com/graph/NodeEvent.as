package net.vdombox.PowerPack.com.graph
{
	import flash.events.Event;
	
	public class NodeEvent extends Event
	{
    	public static const DISPOSED:String = "disposed";
    	public static const ADDING_TRANSITION:String = "addingTransition";
    	
    	public static const TEXT_CHANGED:String = "textChanged";
    	public static const CATEGORY_CHANGED:String = "categoryChanged";
    	public static const TYPE_CHANGED:String = "typeChanged";
    	public static const ENABLED_CHANGED:String = "enabledChanged";
    	public static const BREAKPOINT_CHANGED:String = "breakpointChanged";
    	public static const SELECTED_CHANGED:String = "selectedChanged";

		public function NodeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}