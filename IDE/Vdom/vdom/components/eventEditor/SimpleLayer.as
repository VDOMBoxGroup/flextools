package vdom.components.eventEditor
{
	import mx.containers.Canvas;
	import mx.controls.HRule;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.VRule;

	public class SimpleLayer extends Canvas
	{
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='delete')]
		[Bindable]
		public var delet:Class;
		
		public function SimpleLayer(str:String = 'test')
		{
			super();
			
			var img:Image = new Image();
				img.source = delet;
				img.x = 3;
				img.y = 2;
			addChild(img);

			var vRule:VRule = new VRule();
				vRule.x = 25;
				vRule.percentHeight = 100;
			addChild(vRule);
			
			var label:Label = new Label();
				label.text = str;
				label.width = 165;
				label.x = vRule.x;
				label.setStyle('textAlign', 'center');
			addChild(label);		
			
			var hRule:HRule = new HRule();
				hRule.y = 17;
				hRule.percentWidth = 100;
			addChild(hRule);
		}
		
	}
}