package net.vdombox.ide.modules.tree.view
{
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.vo.StructureObjectVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.view.components.TreeElement;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class TreeElementMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "TreeElementMediator";
		
		public function TreeElementMediator( viewComponent : Object, structureObjectVO : StructureObjectVO )
		{
			super( NAME + "/" + structureObjectVO.id, viewComponent );
			
			_structureObjectVO = structureObjectVO;
		}
		
		private var _structureObjectVO : StructureObjectVO;
		
		public function get structureObjectVO () : StructureObjectVO
		{
			return _structureObjectVO;
		}
		
		public function get treeElement() : TreeElement
		{
			return viewComponent as TreeElement;
		}
		
		override public function onRegister() : void
		{
			addEventListeners();
			
			treeElement.x = structureObjectVO.left;
			treeElement.y = structureObjectVO.top;
			
			sendNotification( ApplicationFacade.get
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.SELECTED_APPLICATION_GETTED );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var messageName : String = notification.getName();
			var messageBody : Object = notification.getBody();
			
			switch ( messageName )
			{
				case ApplicationFacade.SELECTED_APPLICATION_GETTED:
				{
					
					sendNotification( ApplicationFacade.GET_APPLICATION_STRUCTURE, messageBody );
					break;
				}
			}
		}
		
		private function addEventListeners() : void
		{
			treeElement.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}
		
		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			
		}
	}
}