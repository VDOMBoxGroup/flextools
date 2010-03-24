package net.vdombox.ide.modules.events.view.components
{
	import net.vdombox.ide.common.vo.EventVO;
	import net.vdombox.ide.modules.events.view.skins.WorkAreaSkin;
	
	import spark.components.SkinnableContainer;
	import spark.skins.spark.PanelSkin;
	
	public class WorkArea extends SkinnableContainer
	{
		public function WorkArea()
		{
			setStyle( "skinClass", WorkAreaSkin );
		}
		
		public function set dataProvider( value : Array ) : void
		{
			var eventObject : Object;
			var eventElement : EventElement;
			
			removeAllElements();
			
			for each( eventObject in value )
			{
				eventElement = new EventElement();
				eventElement.data = eventObject.eventVO;
				
				addElement( eventElement );
			}
		}
	}
}