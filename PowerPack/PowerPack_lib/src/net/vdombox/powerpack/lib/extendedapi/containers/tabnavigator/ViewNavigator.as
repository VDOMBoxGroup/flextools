package net.vdombox.powerpack.lib.extendedapi.containers.tabnavigator
{
	import mx.containers.TabNavigator;
	
	public class ViewNavigator extends TabNavigator{
		
		/*
		Use the ViewBar instance as the tabBar as the tabBar.
		Since ViewBar extends TabBar, the cooercion succeeds
		*/
		override protected function createChildren():void{
	        if (!tabBar)
			{
				tabBar = new ViewBar();
				tabBar.name = "tabBar";
				tabBar.focusEnabled = false;
				tabBar.styleName = this;
	
				tabBar.setStyle("borderStyle", "none");
				tabBar.setStyle("paddingTop", 0);
				tabBar.setStyle("paddingBottom", 0);
				
				rawChildren.addChild(tabBar);
				
			}
			super.createChildren();
		}
	}
}