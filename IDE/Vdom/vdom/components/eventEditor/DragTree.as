package vdom.components.eventEditor
{
	import mx.controls.Tree;
	import mx.core.ClassFactory;
	import mx.events.DragEvent;

	public class DragTree extends Tree
	{
		public function DragTree()
		{
			super();
								
			dragEnabled = true;
			labelField = "@label";
			showRoot = false;
			percentHeight = 100;//width = 200;
			percentWidth = 100;
			//itemRenderer = new ClassFactory(IconTreeItemRenderer);
			
		  	addEventListener(DragEvent.DRAG_COMPLETE, onTreeDragComplete);
		}
		
		private function onTreeDragComplete(drEvt:DragEvent):void
		{
			drEvt.preventDefault();
		}
		
	}
}