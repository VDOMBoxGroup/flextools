package net.vdombox.ide.modules.resourceBrowser.view
{
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.modules.resourceBrowser.ApplicationFacade;
	import net.vdombox.ide.modules.resourceBrowser.model.SessionProxy;
	import net.vdombox.ide.modules.resourceBrowser.view.components.PreviewArea;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class PreviewAreaMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "PreviewAreaMediator";

		public function PreviewAreaMediator( viewComponent : PreviewArea )
		{
			super( NAME, viewComponent );
		}

		public function get previewArea() : PreviewArea
		{
			return viewComponent as PreviewArea;
		}

		private var sessionProxy : SessionProxy;

		private var isActive : Boolean;

		override public function onRegister() : void
		{
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			isActive = false;

			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();

			clearData();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.BODY_START );
			interests.push( ApplicationFacade.BODY_STOP );

			interests.push( ApplicationFacade.SELECTED_RESOURCE_CHANGED );
			
			interests.push( ApplicationFacade.RESOURCE_LOADED );
			interests.push( ApplicationFacade.RESOURCE_DELETED );
			

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			if ( !isActive && name != ApplicationFacade.BODY_START )
				return;

			switch ( notification.getName() )
			{
				case ApplicationFacade.BODY_START:
				{
					if ( sessionProxy.selectedApplication )
					{
						isActive = true;

						break;
					}
				}

				case ApplicationFacade.BODY_STOP:
				{
					isActive = false;

					clearData();

					break;
				}

				case ApplicationFacade.SELECTED_RESOURCE_CHANGED:
				{
					previewArea.resourceVO = sessionProxy.selectedResource;

					break;
				}
					
				case ApplicationFacade.RESOURCE_LOADED:
				{
					previewArea.resourceVO = body as ResourceVO;
					
					break;
				}
					
				case ApplicationFacade.RESOURCE_DELETED:
				{
					previewArea.resourceVO = null;
					
					break;
				}
			}
		}

		private function addHandlers() : void
		{
		}

		private function removeHandlers() : void
		{
		}

		private function clearData() : void
		{
			previewArea.resourceVO = null;
		}
	}
}