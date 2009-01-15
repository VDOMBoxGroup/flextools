package vdom.components.eventEditor
{
	import mx.controls.listClasses.ListItemRenderer;
	import mx.controls.treeClasses.TreeItemRenderer;

	public class EventItemRender extends ListItemRenderer // TreeItemRenderer
	{
		public function EventItemRender()
		{
			super();
		}
		
		public override function set enabled(value:Boolean):void 
		{
				if(!data) {
					super.enabled = value;
					return;
				}
				
				var val:XML = XML(data);
				
				var enableFlag:String = val.@enabled[0];
				
				
				if(enableFlag == 'false')
					super.enabled = false;
				else
					super.enabled = value;
		}
		
	}
}