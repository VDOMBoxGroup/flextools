package vdom.controls.resourceBrowser
{
import flash.events.Event;

public class ListItemEvent extends Event
{
	public static var DELETE_RESOURCE : String = "delete resource";
	
	public var resourceID : String;
	public var resourceName : String;
	public var resourceType : String;
	
	public function ListItemEvent( type : String, 
								   bubbles : Boolean = false,
							 	   cancelable : Boolean = true,
							 	   resourceID : String = null,
							 	   resourceName : String = null,
							 	   resourceType : String = null )
	{
		super( type, bubbles, cancelable );

		this.resourceID = resourceID;
		this.resourceName = resourceName;
		this.resourceType = resourceType;
	}
	
	override public function clone() : Event
	{
		return new ListItemEvent( type, bubbles, cancelable, resourceID, resourceName, resourceType);
	}
}
}