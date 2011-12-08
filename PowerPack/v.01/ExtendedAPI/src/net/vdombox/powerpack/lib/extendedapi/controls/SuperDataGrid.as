package src.net.vdombox.powerpack.lib.extendedapi.controls
{
	import mx.controls.AdvancedDataGrid;

	public class SuperDataGrid extends AdvancedDataGrid
	{
		public function SuperDataGrid()
		{
			super();
		}
		
		override public function get firstVisibleItem():Object
		{
			if(listItems && listItems.length>0 && listItems[0] && listItems[0].length>0)
				return super.firstVisibleItem;
			return null;
		}
	}
}