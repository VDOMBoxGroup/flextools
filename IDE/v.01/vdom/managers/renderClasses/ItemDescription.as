package vdom.managers.renderClasses
{
import vdom.containers.IItem;		

public class ItemDescription
{	
	public var itemId : String;
	public var staticFlag : String;
	public var parentId : String;
	public var fullPath : String;
	public var zindex : uint;
	public var hierarchy : uint;
	public var order : uint;
	public var item : IItem;
	public var XMLPresentation : XML;
}
}