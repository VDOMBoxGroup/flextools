package net.vdombox.ide.modules.wysiwyg.view.components
{
	import flash.display.BlendMode;
	import flash.events.Event;
	
	import mx.controls.HTML;
	import mx.core.ScrollPolicy;
	
	import spark.components.Scroller;
	
	public class HTML extends mx.controls.HTML
	{
		public function HTML()
		{
			super();
		}
		
		private var _overflow:String = "auto";
		
		public function get overflow():String
		{
			return _overflow;
		}

		public function set overflow(value:String):void
		{
			_overflow = value;
			
			switch(value)
			{
				case "scroll":
					verticalScrollPolicy = horizontalScrollPolicy = ScrollPolicy.ON;
					break;
				
				case "visible":
					percentWidth = percentHeight = 100;
				case "hidden":
					verticalScrollPolicy = horizontalScrollPolicy = ScrollPolicy.OFF;
					break;
					
				case "auto":
				default:
					verticalScrollPolicy = horizontalScrollPolicy = ScrollPolicy.AUTO;
					break;
				
			}
		}

		override public function set blendMode(value:String):void
		{ 
			super.blendMode = value || BlendMode.DARKEN;
		}
		
		/**
		 * Used to disable mouse events for all children except Scroller.
		 * Use "true" when you have no need to change content. 
		 * It allows you to move the components for any point.  
		 *  
		 * @param value
		 * 
		 */		
		public function set locked (value:Boolean) : void
		{
			if (!value)
				return;
			
			for (var i:uint=0; i<numChildren; i++)
			{
				var child:* = getChildAt(i);
				
				if ((child != null) && !(child is Scroller) && child.hasOwnProperty("mouseChildren"))
					child.mouseChildren = false;
			}
		}
		
	}
}