package vdom.components.edit.containers
{
import mx.controls.Tree;

public class OTree extends Tree
{
		
	public function OTree()
	{
		super();
	}
	
	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		
		if (!collection)
			return;
			
		var newHeight:Number = collection.length * rowHeight + rowHeight;
		if(newHeight != height)
			height = newHeight;
	}
}
}