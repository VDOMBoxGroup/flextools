package vdom.components.eventEditor
{
	import mx.controls.Tree;
	import mx.events.DragEvent;
	
	import vdom.utils.IconUtil;

	public class DragTree extends Tree
	{
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='plus')]
		[Bindable]
		public var plus:Class;
		

	
		public function DragTree()
		{
			super();
								
			dragEnabled = true;
			labelField = "@label";
			showRoot = false;
			percentHeight = 100;//width = 200;
			percentWidth = 100;
			iconFunction = getIcon;
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
		
		private function getIcon(value:Object):Class 
		{
			var xmlData:XML = XML(value);
		
			if (xmlData.@resourceID.toXMLString() =='')
				return plus;
		
			var data:Object = {typeId:xmlData.@Type, resourceId:xmlData.@resourceID}
		 	
	 		return IconUtil.getClass(this, data, 16, 16);
		}
	
	}
}