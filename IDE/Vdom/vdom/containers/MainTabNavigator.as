package vdom.containers
{
	import mx.containers.TabNavigator;
	import mx.controls.TabBar;
	import mx.controls.Button;
	import flash.events.FocusEvent;
	
	[Style(name="tabPaddingLeft", type="Number", format="Length", inherit="no")]
	
	public class MainTabNavigator extends TabNavigator	
	{
		public function MainTabNavigator()
		{
			super();
		}
		
	    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
	    {
	        super.updateDisplayList(unscaledWidth, unscaledHeight);
	
	        tabBar.setStyle("paddingLeft", getStyle("tabPaddingLeft"));
	
	        switch (getStyle("horizontalAlign"))
	        {
	        case "left":
	            tabBar.move(0, tabBar.y);
	            break;
	        case "right":
	            tabBar.move(unscaledWidth - tabBar.width, tabBar.y);
	            break;
	        case "center":
	            tabBar.move((unscaledWidth - tabBar.width) / 2, tabBar.y);
	        }
	    }
	    
	     override protected function focusInHandler(event:FocusEvent):void
	    {
	        super.focusInHandler(event);
	        
	        // When the TabNavigator has focus, the Focus Manager
	        // should not treat the Enter key as a click on
	        // the default pushbutton.
	        if (event.target == this)
	            focusManager.defaultButtonEnabled = false;
	    }
	    
	    override protected function focusOutHandler(event:FocusEvent):void
	    {
	        super.focusOutHandler(event);
	
	        if (focusManager && event.target == this)
	            focusManager.defaultButtonEnabled = true;
	    }
	    
	}
}