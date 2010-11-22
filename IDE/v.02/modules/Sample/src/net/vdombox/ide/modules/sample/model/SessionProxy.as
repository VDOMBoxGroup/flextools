/*Прокси для хранения определенных данных на период одной сессии (пока модуль является текущим). В данном
случае могут хранится выбранные в данный момент проложение, страница и объект.*/
package net.vdombox.ide.modules.sample.model
{
	import flash.utils.Dictionary;
	
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.sample.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	public class SessionProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "SessionProxy";
		
		public static const SELECTED_APPLICATION : String = "selectedApplication";
		public static const SELECTED_PAGE : String = "selectedPage";
		public static const SELECTED_OBJECT : String = "selectedObject";
		
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
			//TODO: Переписать все SessionProxy в модулях на этот.
			if ( data[ SELECTED_APPLICATION ] == value )
				return;
			
			if ( data[ SELECTED_APPLICATION ] && value && data[ SELECTED_APPLICATION ].id == value.id )
				return;
			
			data[ SELECTED_APPLICATION ] = value;
			data[ SELECTED_PAGE ] = null;
			data[ SELECTED_OBJECT ] = null;
			
			isSelectedApplicationChanged = true;
			
			sendNotifications();
		}
		
		public function get selectedPage() : PageVO
		{
			return data[ SELECTED_PAGE ];
		}
		
		public function set selectedPage( value : PageVO ) : void
		{
			if ( data[ SELECTED_PAGE ] == value )
				return;
			
			if ( data[ SELECTED_PAGE ] && value && data[ SELECTED_PAGE ].id == value.id )
				return;
			
			data[ SELECTED_PAGE ] = value;
			data[ SELECTED_OBJECT ] = null;
			
			isSelectedPageChanged = true;
			
			sendNotifications();
		}
		
		public function get selectedObject() : ObjectVO
		{
			return data[ SELECTED_OBJECT ];
		}
		
		public function set selectedObject( value : ObjectVO ) : void
		{
			if ( data[ SELECTED_OBJECT ] == value )
				return;
			
			if ( data[ SELECTED_OBJECT ] && value && data[ SELECTED_OBJECT ].id == value.id )
				return;
			
			data[ SELECTED_OBJECT ] = value;
			isSelectedObjectChanged = true;
			
			sendNotifications();
		}
		
//		используется для установки сразу всех значений (selectedApp, selectetPages и selectedObj )
		public function setStates( states : Object ) : void
		{
			var selectedApplicationVO : ApplicationVO = states.selectedApplication as ApplicationVO;
			var selectedPageVO : PageVO = states.selectedPage as PageVO;
			var selectedObjectVO : ObjectVO = states.selectedObject as ObjectVO;
			
			if ( ( selectedApplicationVO && data[ SELECTED_APPLICATION ] && selectedApplicationVO.id != data[ SELECTED_APPLICATION ].id ) ||
				selectedApplicationVO != data[ SELECTED_APPLICATION ] )
			{
				data[ SELECTED_APPLICATION ] = states.selectedApplication;
				isSelectedApplicationChanged = true;
			}
			
			if ( ( selectedPageVO && data[ SELECTED_PAGE ] && selectedPageVO.id != data[ SELECTED_PAGE ].id ) ||
				selectedPageVO != data[ SELECTED_PAGE ] )
			{
				data[ SELECTED_PAGE ] = states.selectedPage;
				isSelectedPageChanged = true;
			}
			
			if ( ( selectedObjectVO && data[ SELECTED_OBJECT ] && selectedObjectVO.id != data[ SELECTED_OBJECT ].id ) ||
				selectedObjectVO != data[ SELECTED_OBJECT ] )
			{
				data[ SELECTED_OBJECT ] = states.selectedObject;
				isSelectedObjectChanged = true;
			}
			
			sendNotifications();
		}
		
//		очистка всех значений
		public function cleanup() : void
		{
			data = {};
		}
		
//		отправка уведомлений о изменении значений
		private function sendNotifications() : void
		{
			if ( isSelectedApplicationChanged )
			{
				isSelectedApplicationChanged = false;
				sendNotification( ApplicationFacade.SELECTED_APPLICATION_CHANGED, data[ SELECTED_APPLICATION ] );
			}
			
			if ( isSelectedPageChanged )
			{
				isSelectedPageChanged = false;
				sendNotification( ApplicationFacade.SELECTED_PAGE_CHANGED, data[ SELECTED_PAGE ] );
			}
			
			if ( isSelectedObjectChanged )
			{
				isSelectedObjectChanged = false;
				sendNotification( ApplicationFacade.SELECTED_OBJECT_CHANGED, data[ SELECTED_OBJECT ] );
			}
		}
	}
}