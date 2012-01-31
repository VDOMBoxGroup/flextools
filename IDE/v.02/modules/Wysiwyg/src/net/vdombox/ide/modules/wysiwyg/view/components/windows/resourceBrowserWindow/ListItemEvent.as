package net.vdombox.ide.modules.wysiwyg.view.components.windows.resourceBrowserWindow
{
import flash.events.Event;

import net.vdombox.ide.common.model.vo.ResourceVO;


public class ListItemEvent extends Event
{
	public static var LOAD_RESOURCE : String = "load resource";
	public static var DELETE_RESOURCE : String = "delete resource";
	
//	public var resourceID : String;
//	public var resourceName : String;
//	public var resourceType : String;
	public var resource : ResourceVO;
	
	/**
	 * @param type : String,
	 * @param bubbles : Boolean = false,
	 * @param cancelable : Boolean = true,
//	 * @param resourceID: String = null,
//	 * @param resourceName: String = null,
//	 * @param resourceType: String = null,
	 * @param resource : ResourceVO = null 
	 */
	public function ListItemEvent( type : String, 
								   bubbles : Boolean = false,
							 	   cancelable : Boolean = true,
//							 	   resourceID : String = null )
//							 	   resourceName : String = null,
//							 	   resourceType : String = null,
								   resource : ResourceVO = null )
	{
		super( type, bubbles, cancelable );

//		this.resourceID = resourceID;
//		this.resourceName = resourceName;
//		this.resourceType = resourceType;
		this.resource = resource;
	}
	
	override public function clone() : Event
	{
		return new ListItemEvent( type, bubbles, cancelable, resource );//,resourceName, resourceType);
	}
}
}