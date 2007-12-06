package vdom.components.treeEditor
{
	import mx.containers.Canvas;
	import mx.controls.DataGrid;
	import mx.collections.ArrayCollection;
	import mx.controls.dataGridClasses.DataGridColumn;

	public class LevelsMenu extends Canvas
	{
		private var dataGrid:DataGrid;
		private var initDG:ArrayCollection = new ArrayCollection([
                {Artist:'Pavement', Album:'Slanted and Enchanted', 
                    Price:11.99, Cover:'slanted.jpg'},
                {Artist:'Pavement', Album:'Brighten the Corners', 
                    Price:11.99, Cover:'brighten.jpg'}
            ]);
		
		public function LevelsMenu()
		{
			super();
			
			dataGrid = new DataGrid();
			dataGrid.dataProvider = initDG;	
			
			dataGrid.columns.aaa = 'asd';
//			dataGrid.
			//var colums:DataGridColumn = new DataGridColumn();
	//		colums.dataField = 'Art';	
			
//			dataGrid.addChild(
			
		}
		
	}
}