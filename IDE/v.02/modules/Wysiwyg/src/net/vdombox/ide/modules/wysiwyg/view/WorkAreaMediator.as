package net.vdombox.ide.modules.wysiwyg.view
{
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.model.vo.ItemVO;
	import net.vdombox.ide.modules.wysiwyg.view.components.WorkArea;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.List;
	import spark.skins.spark.ListSkin;

	public class WorkAreaMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "WorkAreaMediator";

		public function WorkAreaMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}

		private var sessionProxy : SessionProxy;

		private var isSelectedPageVOChanged : Boolean;
		private var isSelectedObjectVOChanged : Boolean;

		public function get workArea() : WorkArea
		{
			return viewComponent as WorkArea;
		}

		override public function onRegister() : void
		{
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			addHandlers();

			isSelectedPageVOChanged = true;
			isSelectedObjectVOChanged = true;

			commitProperties();
		}

		override public function onRemove() : void
		{
			sessionProxy = null;

			removeHandlers();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.SELECTED_PAGE_CHANGED );
			interests.push( ApplicationFacade.RENDER_DATA_CHANGED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			switch ( name )
			{
				case ApplicationFacade.SELECTED_PAGE_CHANGED:
				{
					isSelectedPageVOChanged = true;
					commitProperties();
					break;
				}
					
				case ApplicationFacade.RENDER_DATA_CHANGED:
				{
					workArea.itemVO = body as ItemVO;

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

		private function commitProperties() : void
		{
			if ( isSelectedPageVOChanged )
			{
				isSelectedPageVOChanged = false;

				if ( sessionProxy.selectedPage )
					sendNotification( ApplicationFacade.GET_PAGE_WYSIWYG, sessionProxy.selectedPage );
			}

			if ( isSelectedObjectVOChanged )
			{
				isSelectedObjectVOChanged = false;

			}
		}
	}
}