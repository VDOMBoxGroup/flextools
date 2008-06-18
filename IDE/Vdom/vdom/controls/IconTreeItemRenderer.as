package vdom.controls
{
	import mx.controls.treeClasses.TreeItemRenderer;
	import mx.controls.treeClasses.TreeListData;
	
	import vdom.managers.FileManager;
	import vdom.utils.IconUtil;

	public class IconTreeItemRenderer extends TreeItemRenderer
	{
		private var fileManager:FileManager;
		
		public function IconTreeItemRenderer()
		{
			super();
			fileManager = FileManager.getInstance();
		}
		
		 override public function set data(value:Object):void {
		 	
            super.data = value;
            
            if(!value) 	return;
            
            var data:Object = {typeId:value.@Type, resourceId:value.@resourceID}
            
            TreeListData(super.listData).icon = IconUtil.getClass(this, data, 16, 16);
            
        }  
	}
}