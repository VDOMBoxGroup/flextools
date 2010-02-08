package net.vdombox.ide.modules.tree.view
{
	import mx.events.FlexEvent;

	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.vo.LinkageVO;
	import net.vdombox.ide.modules.tree.model.vo.StructureElementVO;
	import net.vdombox.ide.modules.tree.view.components.Arrow;
	import net.vdombox.ide.modules.tree.view.components.Body;
	import net.vdombox.ide.modules.tree.view.components.TreeElement;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class BodyMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "BodyMediator";

		public function BodyMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}

		public var selectedApplication : ApplicationVO;

		public var pages : Array;

		public var structure : Array;

		public var selectedPage : PageVO;

		public var treeElements : Object;

		public function get body() : Body
		{
			return viewComponent as Body;
		}

		public function createTreeElements( pages : Array, structureElements : Array ) : void
		{
			this.pages = pages;

			structure = structureElements;

			var pageVO : PageVO;
			var treeElement : TreeElement;

			for each ( pageVO in pages )
			{
				treeElement = new TreeElement();

				treeElements[ pageVO.id ] = treeElement;

				body.main.addElement( treeElement );

				sendNotification( ApplicationFacade.TREE_ELEMENT_CREATED, { viewComponent: treeElement,
									  pageVO: pageVO, structureElementVO: getStructureElement( pageVO ) } );
			}
		}

		public function createArrows( linkages : Array ) : void
		{
			var linkageVO : LinkageVO;

			var arrow : Arrow;

			for each ( linkageVO in linkages )
			{
				arrow = new Arrow();

				body.main.addElement( arrow );

				sendNotification( ApplicationFacade.ARROW_CREATED, { viewComponent: arrow, linkageVO: linkageVO } );
			}
		}

		override public function onRegister() : void
		{
			addHandlers();

			treeElements = {};
		}

		override public function onRemove() : void
		{
			removeHandlers();

			treeElements = null;
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var messageName : String = notification.getName();
			var messageBody : Object = notification.getBody();
		}

		private function addHandlers() : void
		{
			body.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}

		private function removeHandlers() : void
		{
			body.removeEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}

		private function getStructureElement( pageVO : PageVO ) : StructureElementVO
		{
			var result : StructureElementVO;

			for each ( var structureElementVO : StructureElementVO in structure )
			{
				if ( structureElementVO.id == pageVO.id )
				{
					result = structureElementVO;
					break;
				}
			}

			return result;
		}

		private function getPageVOByID( pageID : String ) : PageVO
		{
			var result : PageVO;

			for each ( var pageVO : PageVO in pages )
			{
				if ( pageVO.id == pageID )
				{
					result = pageVO;
					break;
				}
			}

			return result;
		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			sendNotification( ApplicationFacade.BODY_CREATED, body );
		}
	}
}