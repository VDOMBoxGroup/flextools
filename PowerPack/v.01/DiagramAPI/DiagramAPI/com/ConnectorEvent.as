package DiagramAPI.com
{
	import flash.events.Event;
	
	public class ConnectorEvent extends Event
	{
    	public static const LABEL_CHANGED:String = "labelChanged";
    	public static const DATA_CHANGED:String = "dataChanged";
    	public static const ENABLED_CHANGED:String = "enabledChanged";
    	public static const HIGHLIGHTED_CHANGED:String = "highlightedChanged";

    	public static const FROM_OBJECT_CHANGED:String = "fromObjectChanged";
    	public static const TO_OBJECT_CHANGED:String = "toObjectChanged";
    	
    	public static const TYPE_CHANGED:String = "typeChanged";
    	public static const DIRECTION_CHANGED:String = "directionChanged";
    		
    	public static const DISPOSED:String = "disposed";

		public function ConnectorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}