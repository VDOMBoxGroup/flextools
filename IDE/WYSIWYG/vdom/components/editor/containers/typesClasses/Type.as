package vdom.components.editor.containers.typesClasses
{
import mx.containers.VBox;
import flash.events.MouseEvent;
import mx.controls.Image;
import mx.controls.Label;
import mx.core.DragSource;
import vdom.components.editor.managers.VdomDragManager;
import mx.managers.SystemManager;
	
public class Type extends VBox
{
	protected var _id:uint;
	
	private var typeIcon:Image;
	private var typeLabel:Label;
	
	private var _iconSource:String;

	
	public function Type(id:uint, iconSource:String, label:String)
	{
		super();
		this._id = id;
		if(iconSource != '') {
			_iconSource = iconSource;
			typeIcon = new Image();
			typeIcon.source = iconSource;
		}
		
		typeLabel = new Label();
		typeLabel.text = label;
		
		addChild(typeIcon);
		addChild(typeLabel);
		
		this.addEventListener(MouseEvent.MOUSE_DOWN, dragIt);
	}
	
	private function dragIt(event:MouseEvent):void {
		var dragInitiator:Type = Type(event.currentTarget);
		var ds:DragSource = new DragSource();
		var dataObject:Object = {typeId:_id, offX:dragInitiator.mouseX, offY:dragInitiator.mouseY};
		ds.addData(dataObject, 'Object');
		var proxy:Image = new Image();
		proxy.source = typeIcon.source;
		proxy.width = 40;
		proxy.height = 40;
		VdomDragManager.doDrag(dragInitiator, ds, event, proxy, proxy.width/2 - dragInitiator.mouseX, proxy.height/2 - dragInitiator.mouseY);
	}
	
}
}