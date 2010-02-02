package net.vdombox.ide.modules.tree.view
{
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.vo.StructureElementVO;
	import net.vdombox.ide.modules.tree.view.components.TreeElementz;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class TreeElementMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "TreeElementMediator";

		public function TreeElementMediator( viewComponent : Object, pageVO : PageVO, structureElementVO : StructureElementVO )
		{
			super( NAME + ApplicationFacade.DELIMITER + pageVO.id, viewComponent );

			_pageVO = pageVO;

			_structureElementVO = structureElementVO ? structureElementVO : new StructureElementVO( pageVO.id );
		}

		private var _pageVO : PageVO;

		private var _structureElementVO : StructureElementVO;
		
		private var _typeVO : TypeVO;

		public function get pageVO() : PageVO
		{
			return _pageVO;
		}

		public function get structureElementVO() : StructureElementVO
		{
			return _structureElementVO;
		}

		public function get treeElement() : TreeElementz
		{
			return viewComponent as TreeElementz;
		}

		override public function onRegister() : void
		{
			addEventListeners();

			treeElement.x = structureElementVO.left;
			treeElement.y = structureElementVO.top;

			structureElementVO.width = treeElement.width;
			structureElementVO.height = treeElement.height;
			
			sendNotification( ApplicationFacade.GET_TYPE, { typeID: pageVO.typeID, recipientID: mediatorName } );
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.TYPE_GETTED + ApplicationFacade.DELIMITER + mediatorName );

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
					
					treeElement.typeIcon.source = resourceVO.data;
					
					sendNotification( ApplicationFacade.GET_RESOURCE, resourceVO );

					break;
				}
			}
		}
		
		private function addEventListeners() : void
		{
		}
	}
}