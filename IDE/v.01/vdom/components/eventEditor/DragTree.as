package vdom.components.eventEditor
{
	import mx.controls.List;
	import mx.events.DragEvent;

	public class DragTree extends List
	{
		[Embed(source='/assets/eventEditor/actions.png')]
		[Bindable]
		public var action:Class;
		
		[Embed(source='/assets/eventEditor/events.png')]
		[Bindable]
		public var event:Class;

	
		public function DragTree()
		{
			super();
								
			dragEnabled = true;
			labelField = "@label";
//			showRoot = true;
			percentHeight = 100;//width = 200;
			percentWidth = 100;
			setStyle('borderColor', '0xFFFFFF');
			
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