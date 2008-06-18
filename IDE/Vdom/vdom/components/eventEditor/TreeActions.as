package vdom.components.eventEditor
{
	public class TreeActions extends DragTree
	{
		public function TreeActions()
		{
			super();
		}
		
		override public function set dataProvider(value:Object):void
		{
			super.dataProvider = value;
		}
	}
}