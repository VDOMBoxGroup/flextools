package vdom.events
{
import flash.events.Event;

public class AddTreeElementEvent extends Event
{
	public static const TREE_ELEMENT_ADDED:String = 'reDraw';
	
	public var treeElementID:String;
	public var resourceID:String;
	public var title:String;
	public var description:String;
	public var type:String;
	
	
	public function TreeEditorEvent(type:String, treeElementID:String='', 
												resourceID:String='',
												title:String='',
												description:String='',
												type:String='', 
												bubbles:Boolean=false, cancelable:Boolean=false)
	{
		super(type, bubbles, cancelable);
		
		this.treeElementID = treeElementID;
		this.resourceID = resourceID;
		this.title = title;
		this.description = description;
		this.type = type;
	}
}
}