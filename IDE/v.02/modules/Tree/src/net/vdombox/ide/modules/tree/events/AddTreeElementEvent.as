package net.vdombox.ide.modules.tree.events
{
import flash.events.Event;

public class AddTreeElementEvent extends Event
{
	public static const TREE_ELEMENT_ADDED:String = 'reDraw';
	
	public var treeElementID:String;
	public var resourceID:String;
	public var title:String;
	public var description:String;
	public var trElementType:String;
	public var typeResourse:String;
	
	
	
	public function AddTreeElementEvent(type:String, treeElementID:String='', 
												resourceID:String='',
												title:String='',
												description:String='',
												treeElementType:String='', 
												typeResourse:String = '',
												bubbles:Boolean=false, cancelable:Boolean=false)
	{
		super(type, bubbles, cancelable);
		
		this.treeElementID = treeElementID;
		this.resourceID = resourceID;
		this.title = title;
		this.description = description;
		this.trElementType = treeElementType;
		this.typeResourse = typeResourse;
	}
}
}