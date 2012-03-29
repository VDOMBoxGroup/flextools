package net.vdombox.powerpack.lib.extendedapi.containers.tabnavigator
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import mx.controls.Button;
	import mx.controls.tabBarClasses.Tab;
	import mx.core.mx_internal;
	
	public class ViewTab extends Tab{
		
		public static const CLOSE_TAB:String = "closeTab";
		
		[Embed("/assets/icons/close_tab.png")]
		public var cancel:Class;
		
		private var closeIcon:DisplayObject;
		private var showClose:Boolean = false;
		
		
		use namespace mx_internal;
		
		public function ViewTab(){
			super();
		}
		
		override protected function createChildren():void{
			super.createChildren();
		}
		override protected function measure():void{
			super.measure();
			measuredMinWidth+=20
			measuredWidth+=20;
		}
		
		/*
		Probably inefficient but fine for quick fix. 
		When the button is rolled over to change the skin,
		the new skin gets added to the next highest depth.
		If the closeIcon is already added, it needs to be
		added to the topmost depth.
		*/
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			try
			{
				removeChild(this.closeIcon);
			}
			catch(e:Error){}
			
			closeIcon = addChild(new cancel());
			
			if(!showClose)
				closeIcon.visible = false;

			this.textField.x-=10;
			
			closeIcon.x = unscaledWidth - (iconWidth * 2 + 2);
			closeIcon.y = (unscaledHeight-iconHeight)/2;
		}
		
		private function get iconWidth () : Number
		{
			return 10;
		}
		
		private function get iconHeight () : Number
		{
			return 10;
		}
		
		override protected function clickHandler(event:MouseEvent):void
		{
			try
			{
				var rect:Rectangle = new Rectangle(closeIcon.x, closeIcon.y, closeIcon.width,closeIcon.height);
				
				if (rect.contains(event.localX,event.localY))
				{
					dispatchEvent(new Event(CLOSE_TAB));
					event.stopImmediatePropagation();
				}
				else
				{
					super.clickHandler(event);
				}
			}
			catch(e:Error)
			{
				super.clickHandler(event);
			}
			
		}
		
		override protected function rollOverHandler(event:MouseEvent):void
		{
			showClose = true;
			
			super.rollOverHandler(event);	
		}
		
		override protected function rollOutHandler(event:MouseEvent):void
		{
			showClose=false;
			
			super.rollOutHandler(event);	
		}
	}
}