package vdom.components.treeEditor
{
	import mx.core.Container;
	
	public class TreeVector extends Vector2
	{
		private var trEl0:Object;
		private var trEl1:Object;
		private var vector:Container = new Container();
		private var curColor:String = '';
		
		public function TreeVector(trEl0:Object, trEl1:Object, level:String = '1'):void
		{
			super( ); 
					
			this.buttonMode = true;
			color = level;
			this.curColor = level;
			this.trEl0 = trEl0;
			this.trEl1 = trEl1;
			createVector (trEl0,  trEl1, level);
		}
		
	
		
		public function updateVector():void
		{
			graphics.clear();
			createVector (trEl0,  trEl1, curColor );
		}
	}
}