package vdom.components.eventEditor
{
	import mx.controls.treeClasses.TreeItemRenderer;

	public class EventItemRender extends TreeItemRenderer
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
				
				if(val.@enabled[0] && val.(@enabled == false))
					super.enabled = false;
				else
					super.enabled = value;
		}
		
	}
}