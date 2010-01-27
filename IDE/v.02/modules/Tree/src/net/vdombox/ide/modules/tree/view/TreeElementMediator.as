package net.vdombox.ide.modules.tree.view
{
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.common.vo.StructureObjectVO;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.view.components.TreeElement;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class TreeElementMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "TreeElementMediator";

		public function TreeElementMediator( viewComponent : Object, pageVO : PageVO, structureObjectVO : StructureObjectVO )
		{
			super( NAME + ApplicationFacade.DELIMITER + pageVO.id, viewComponent );

			_pageVO = pageVO;

			_structureObjectVO = structureObjectVO ? structureObjectVO : new StructureObjectVO( pageVO.id );
		}

		private var _pageVO : PageVO;

		private var _structureObjectVO : StructureObjectVO;
		
		private var _typeVO : TypeVO;

		public function get pageVO() : PageVO
		{
			return _pageVO;
		}

		public function get structureObjectVO() : StructureObjectVO
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

			sendNotification( ApplicationFacade.GET_TYPE, { typeID: pageVO.typeID, recipientID: mediatorName } );
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.TYPE_GETTED + ApplicationFacade.DELIMITER + mediatorName );
			interests.push( ApplicationFacade.RESOURCE_GETTED + ApplicationFacade.DELIMITER + mediatorName );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var messageName : String = notification.getName();
			var messageBody : Object = notification.getBody();

			switch ( messageName )
			{
				case ApplicationFacade.TYPE_GETTED + ApplicationFacade.DELIMITER + mediatorName:
				{
					_typeVO = messageBody as TypeVO;
					
					var resourceVO : ResourceVO = new ResourceVO( _typeVO.id );
					resourceVO.setID( _typeVO.iconID );
						
					sendNotification( ApplicationFacade.GET_RESOURCE, resourceVO );

					break;
				}
					
				case ApplicationFacade.RESOURCE_GETTED + ApplicationFacade.DELIMITER + mediatorName:
				{
					
					break;
				}
			}
		}

		private function addEventListeners() : void
		{
		}
	}
}