package vdom.components.eventEditor
{
	import mx.controls.Tree;
	import mx.events.DragEvent;
	
	import vdom.utils.IconUtil;

	public class DragTree extends Tree
	{
		[Embed(source='/assets/eventEditor/eventEditor.swf', symbol='action')]
		[Bindable]
		public var action:Class;
		
		[Embed(source='/assets/eventEditor/eventEditor.swf', symbol='event')]
		[Bindable]
		public var event:Class;

	
		public function DragTree()
		{
			super();
								
			dragEnabled = true;
			labelField = "@label";
			showRoot = true;
			percentHeight = 100;//width = 200;
//			percentWidth = 100;
			
			//itemRenderer = new ClassFactory(IconTreeItemRenderer);
			
		  	addEventListener(DragEvent.DRAG_COMPLETE, onTreeDragComplete);
		}
		
	//	public var dragItemEnabled:Boolean = true;
		private function onTreeDragComplete(drEvt:DragEvent):void
		{
		//	if(!dragItemEnabled)
				drEvt.preventDefault();
			//else	dragItemEnabled = true;
		}
		
	
	
	}
}