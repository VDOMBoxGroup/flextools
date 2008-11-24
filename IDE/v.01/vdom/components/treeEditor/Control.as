package vdom.components.treeEditor
{
	import mx.containers.Canvas;
	import mx.controls.Button;

	public class Control extends Canvas
	{
		public function Control()
		{
			super();
			
			var bt:Button = new Button();
			addChild(bt);
		}
		
	}
}