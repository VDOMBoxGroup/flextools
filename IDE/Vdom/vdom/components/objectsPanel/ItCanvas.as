package vdom.components.objectsPanel
{
	import mx.controls.treeClasses.TreeItemRenderer;
	import mx.controls.treeClasses.TreeListData;
	
	import vdom.managers.FileManager;
	import vdom.utils.IconUtil;

	public class ItCanvas extends TreeItemRenderer
	{
		private var fileManager:FileManager;
		
		public function ItCanvas()
		{
			super();
			fileManager = FileManager.getInstance();
		}
		
		 override public function set data(value:Object):void {
		 	
            super.data = value;
            
            var data:Object = {typeId:value.@Type, resourceId:value.@resourceID}
            
            TreeListData(super.listData).icon  = IconUtil.getClass(this, data);
        }  
	}
}