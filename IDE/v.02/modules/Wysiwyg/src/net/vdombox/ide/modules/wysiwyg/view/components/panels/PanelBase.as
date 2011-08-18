package net.vdombox.ide.modules.wysiwyg.view.components.panels
{
	import spark.components.Panel;
	import spark.primitives.Rect;

	public class PanelBase extends Panel
	{
		[SkinPart( required="true" )]
		public var tbFill : Rect;
		
		public function PanelBase()
		{
			super();
		}

		public function set titleHeight(value:int):void
		{
			tbFill.height = value;
		}

	}
}