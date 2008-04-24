package vdom.components.objectsPanel
{
	import mx.controls.treeClasses.TreeItemRenderer;
	import mx.controls.treeClasses.TreeListData;

	public class ItCanvas extends TreeItemRenderer
	{

		
		public function ItCanvas()
		{
			super();
		}
		
		 override public function set data(value:Object):void {
		 	
            super.data = value;

        }
        
        public function set result(zzz:*):void {
        	
        	TreeListData(super.listData).icon
        }
        
	}
}