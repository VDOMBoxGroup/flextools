package vdom.components.eventEditor
{
	import mx.containers.Canvas;
	import mx.controls.HRule;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.VRule;

	public class SimpleLayer extends Canvas
	{
		[Embed(source='/assets/eventEditor/actions.png')]
		[Bindable]
		public var _action:Class;
		
		private var img:Image;
		
		public function SimpleLayer	(str:String = 'test')
		{
			super();
			
			img = new Image();
			img.source = _action;
			img.x = 3;
			img.y = 2;
			img.width = 13;
			img.height = 13;
			addChild(img);

			var vRule:VRule = new VRule();
				vRule.x = 20;
				vRule.percentHeight = 100;
			addChild(vRule);
			
			var label:Label = new Label();
				label.text = str;
				label.width = 145;
				label.x = vRule.x;
				label.setStyle('textAlign', 'center');
			addChild(label);		
			
			var hRule:HRule = new HRule();
				hRule.y = 17;
				hRule.percentWidth = 100;
			addChild(hRule);
		}
		
		public function set source(obj:Object):void
		{
			img.source = obj;
		}
		
	}
}