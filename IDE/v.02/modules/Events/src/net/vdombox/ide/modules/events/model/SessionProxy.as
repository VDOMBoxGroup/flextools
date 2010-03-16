package net.vdombox.ide.modules.events.model
{
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.events.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class SessionProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "SessionProxy";

		public static const SELECTED_APPLICATION : String = "selectedApplication";
		public static const SELECTED_PAGE : String = "selectedPage";
		public static const SELECTED_OBJECT : String = "selectedObject";
		public static const NEED_FOR_UPDATE : String = "needForUpdate";

		public function SessionProxy()
		{
			super( NAME, {} );
		}

		private var isSelectedApplicationChanged : Boolean;
		private var isSelectedPageChanged : Boolean;
		private var isSelectedObjectChanged : Boolean;
		
		override public function onRegister() : void
		{
			isSelectedApplicationChanged = false;
			isSelectedPageChanged = false;
			isSelectedObjectChanged = false;
		}
		
		override public function onRemove() : void
		{
			data = null;
		}

		public function get selectedApplication() : ApplicationVO
		{
			return data[ SELECTED_APPLICATION ];
		}

		public function set selectedApplication( value : ApplicationVO ) : void
		{
			if ( data[ SELECTED_APPLICATION ] != value )
			{
				data[ SELECTED_APPLICATION ] = value;
				isSelectedApplicationChanged = true;
				
				sendNotifications();
			}
		}

		public function get selectedPage() : PageVO
		{
			return data[ SELECTED_PAGE ];
		}

		public function set selectedPage( value : PageVO ) : void
		{
			if ( data[ SELECTED_PAGE ] != value )
			{
				data[ SELECTED_PAGE ] = value;
				isSelectedApplicationChanged = true;
				
				sendNotifications();
			}
		}

		public function get selectedObject() : ObjectVO
		{
			return data[ SELECTED_OBJECT ];
		}

		public function set selectedObject( value : ObjectVO ) : void
		{
			if ( data[ SELECTED_OBJECT ] != value )
			{
				data[ SELECTED_OBJECT ] = value;
				isSelectedApplicationChanged = true;
				
				sendNotifications();
			}
		}

		public function setStates( states : Object ) : void
		{
			if( states.selectedApplication && states.selectedApplication  != data[ SELECTED_APPLICATION ] )
			{
				data[ SELECTED_APPLICATION ] = states.selectedApplication;
				isSelectedApplicationChanged = true;
			}
			
			if( states.selectedPage && states.selectedPage  != data[ SELECTED_PAGE ] )
			{
				data[ SELECTED_PAGE ] = states.selectedPage;
				isSelectedPageChanged = true;
			}
			
			if( states.selectedObject && states.selectedObject  != data[ SELECTED_OBJECT ] )
			{
				data[ SELECTED_OBJECT ] = states.selectedObject;
				isSelectedObjectChanged = true;
			}
			
			sendNotifications();
		}
		
		public function getObject( objectID : String ) : Object
		{
			if ( !data.hasOwnProperty( objectID ) )
				data[ objectID ] = {};

			return data[ objectID ];
		}
		
		private function sendNotifications() : void
		{
			if( isSelectedApplicationChanged )
			{
				isSelectedApplicationChanged = false;
				sendNotification( ApplicationFacade.SELECTED_APPLICATION_CHANGED, data[ SELECTED_APPLICATION ] );
			}
			
			if( isSelectedPageChanged )
			{
				isSelectedPageChanged = false;
				sendNotification( ApplicationFacade.SELECTED_PAGE_CHANGED, data[ SELECTED_PAGE ] );
			}
			
			if( isSelectedObjectChanged )
			{
				isSelectedObjectChanged = false;
				sendNotification( ApplicationFacade.SELECTED_OBJECT_CHANGED, data[ SELECTED_OBJECT ] );
			}
		}
	}
}