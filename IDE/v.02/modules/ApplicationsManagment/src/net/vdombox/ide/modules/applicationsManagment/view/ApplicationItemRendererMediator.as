package net.vdombox.ide.modules.applicationsManagment.view
{
	import mx.binding.utils.BindingUtils;
	import mx.events.FlexEvent;

	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsManagment.view.components.ApplicationItemRenderer;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ApplicationItemRendererMediator extends Mediator implements IMediator
	{
		public function ApplicationItemRendererMediator( viewComponent : Object = null )
		{
			super( getNextID(), viewComponent );
		}

		private static const NAME : String = "ApplicationItemRendererMediator";

		private static var serial : Number = 0;

		private static function getNextID() : String
		{
			var id : String = NAME + "/" + serial;
			serial++;
			return id;

		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( mediatorName + "/" + ApplicationFacade.RESOURCE_GETTED );
			interests.push( ApplicationFacade.APPLICATION_EDITED );

			return interests;
		}

		override public function onRegister() : void
		{
			applicationItemRenderer.addEventListener( FlexEvent.DATA_CHANGE, dataChangeHandler );

			refreshProperties();
		}

		override public function handleNotification( notification : INotification ) : void
		{
			switch ( notification.getName() )
			{
				case mediatorName + "/" + ApplicationFacade.RESOURCE_GETTED:
				{
					var resourceVO : ResourceVO = notification.getBody() as ResourceVO;

					BindingUtils.bindSetter( setIcon, resourceVO, "data" );

					break;
				}

				case ApplicationFacade.APPLICATION_EDITED:
				{
					if ( notification.getBody() === applicationItemRenderer.data )
						refreshProperties();

					break;
				}
			}

		}

		private function get applicationItemRenderer() : ApplicationItemRenderer
		{
			return viewComponent as ApplicationItemRenderer;
		}

		private function setIcon( value : * ) : void
		{
			applicationItemRenderer.imageHolder.source = value;
		}

		private function dataChangeHandler( event : FlexEvent ) : void
		{
			refreshProperties();
		}

		private function refreshProperties() : void
		{
			var applicationVO : ApplicationVO = applicationItemRenderer.data as ApplicationVO;

			if ( applicationVO )
			{
				applicationItemRenderer.nameLabel.text = applicationVO.name;
				applicationItemRenderer.description.text = applicationVO.description;

				applicationItemRenderer.pagesCount.text = "Pages: " + applicationVO.numberOfPages.toString();
				applicationItemRenderer.objectsCount.text = "Objects: " + applicationVO.numberOfObjects.toString();
			}
			else
			{
				applicationItemRenderer.nameLabel.text = "";
				applicationItemRenderer.description.text = "";

				applicationItemRenderer.pagesCount.text = "Pages: ";
				applicationItemRenderer.objectsCount.text = "Objects: ";
			}
		}
	}
}