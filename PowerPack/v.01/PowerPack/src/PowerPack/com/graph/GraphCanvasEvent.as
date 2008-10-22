package PowerPack.com.graph
{
	import flash.events.Event;
	
	public class GraphCanvasEvent extends Event
	{
    	public static const DISPOSED:String = "disposed";
    	public static const ADDING_TRANSITION:String = "addingTransition";
    	
    	public static const GRAPH_CHANGED:String = "graphChanged";

		public function GraphCanvasEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}