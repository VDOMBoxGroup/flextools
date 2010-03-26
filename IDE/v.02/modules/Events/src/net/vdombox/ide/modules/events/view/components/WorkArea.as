package net.vdombox.ide.modules.events.view.components
{
	import net.vdombox.ide.common.vo.ApplicationEventsVO;
	import net.vdombox.ide.common.vo.ClientActionVO;
	import net.vdombox.ide.common.vo.EventVO;
	import net.vdombox.ide.common.vo.ServerActionVO;
	import net.vdombox.ide.modules.events.view.skins.WorkAreaSkin;
	
	import spark.components.SkinnableContainer;
	import spark.skins.spark.PanelSkin;

	public class WorkArea extends SkinnableContainer
	{
		public function WorkArea()
		{
			setStyle( "skinClass", WorkAreaSkin );
		}

		private var applicationEventsVO : ApplicationEventsVO;
		
		public function set dataProvider( value : ApplicationEventsVO ) : void
		{
			applicationEventsVO = value;

			var actions : Object = {};
			var events : Object = {};

			var actionElement : ActionElement;
			var eventElement : EventElement;

			var actionVO : Object;
			var event : Object;
			
			var clientActionVO : ClientActionVO;
			var serverActionVO : ServerActionVO;
			var eventVO : EventVO;
			
			var linkage : Linkage;

			removeAllElements();

			for each ( clientActionVO in applicationEventsVO.clientActions )
			{
				actionElement = new ActionElement();
				actions[ clientActionVO.id ] = actionElement;

				actionElement.data = clientActionVO;

				addElement( actionElement );
			}

			for each ( serverActionVO in applicationEventsVO.serverActions )
			{
				actionElement = new ActionElement();
				actions[ serverActionVO.id ] = actionElement;

				actionElement.data = serverActionVO;

				addElement( actionElement );
			}
			
			for each ( event in applicationEventsVO.events )
			{
				eventElement = new EventElement();
				eventElement.data = event.eventVO;
				
				for each( actionVO in event.actions )
				{
					actionElement = actions[ actionVO.id ] ? actions[ actionVO.id ] : null;
					
					if( actionElement )
					{
						linkage = new Linkage();
						linkage.source = eventElement;
						linkage.target = actionElement;
						
						addElement( linkage );
					}
				}
				
				addElement( eventElement );
			}

			
			
//			for each( eventObject in value )
//			{
//				eventElement = new EventElement();
//				eventElement.data = eventObject.eventVO;
//				
//				addElement( eventElement );
//				
//				for each( actionObject in eventObject.actions )
//				{
//					if( !actionsObject[ actionObject.id ] )
//					{
//						actionElement = new ActionElement();
//						actionsObject[ actionObject.id ] = actionElement;
//					}
//					else
//					{
//						actionElement = actionsObject[ actionObject.id ];
//					}
//					
//					actionElement.data = actionObject;
//					
//					
//					addElement(actionElement );
//					
//				}
//			}
		}
	}
}