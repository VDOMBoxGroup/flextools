package net.vdombox.ide.core.view
{
	import flash.desktop.NativeApplication;
	
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.ServerProxy;
	import net.vdombox.ide.core.model.StatesProxy;
	import net.vdombox.ide.core.model.TypesProxy;
	import net.vdombox.ide.core.view.components.InitialWindow;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.Window;

	/**
	 * @flowerModelElementId _DGeLQEomEeC-JfVEe_-0Aw
	 */
	public class VdomIDEMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ApplicationMediator";

		public function VdomIDEMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );

			application.nativeWindow.close();
			NativeApplication.nativeApplication.autoExit = false;
		}

		protected function get application() : VdomIDE
		{
			return viewComponent as VdomIDE
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.INITIAL_WINDOW_OPENED );

//			interests.push( ApplicationFacade.MAIN_WINDOW_OPENED );
			interests.push( TypesProxy.TYPES_LOADED );
			
			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();

			switch ( name )
			{
				case TypesProxy.TYPES_LOADED:
				{
//					if (statesProxy.selectedApplication)
//						sendNotification( ApplicationFacade.OPEN_MAIN_WINDOW );
//					else
					var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
					if ( !serverProxy.reconected )
						sendNotification( ApplicationFacade.OPEN_APPLICATION_MANAGER );

					break;
				}

				case ApplicationFacade.INITIAL_WINDOW_OPENED:
				{
					sendNotification( ApplicationFacade.LOAD_MODULES_REQUEST );

					break;
				}

//				case ApplicationFacade.MAIN_WINDOW_OPENED:
//					{
//						sendNotification( ApplicationFacade.LOAD_MODULES );
//
//						break;
//					}
			}
			
		}
		
		private function get statesProxy() : StatesProxy
		{
			return facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
		}
	}
}