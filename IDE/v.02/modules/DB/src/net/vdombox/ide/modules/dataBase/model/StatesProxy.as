package net.vdombox.ide.modules.dataBase.model
{
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;

	public class StatesProxy extends net.vdombox.ide.common.model.StatesProxy
	{
		public static const NAME : String = "StatesProxyDataBase";
		
		public static const SELECTED_APPLICATION : String = "selectedApplication";
		public static const SELECTED_PAGE : String = "selectedPage";
		public static const SELECTED_OBJECT : String = "selectedObject";
		public static const SELECTED_RESOURCE : String = "selectedResource";
		
		public static const CHANGE_SELECTED_RESOURCE_REQUEST : String = "changeSelectedResourceRequest";
		public static const SELECTED_RESOURCE_CHANGED : String = "selectedResourceChanged";
		
		//pipe
		public static const PROCESS_STATES_PROXY_MESSAGE 		: String = "processStatesProxyMessage";
		
		//states
		public static const GET_ALL_STATES 	  : String = "getAllStates";
		public static const ALL_STATES_GETTED : String = "allStatesGetted";
		
		public static const SET_ALL_STATES 	  : String = "setAllStates";
		public static const ALL_STATES_SETTED : String = "allStatesSetted";
		
		//application
		public static const SELECTED_APPLICATION_CHANGED : String = "selectedApplicationChanged";
		
		//page
		public static const SELECTED_PAGE_CHANGED : String = "selectedPageChanged";
		
		public static const CHANGE_SELECTED_PAGE_REQUEST : String = "changeSelectedPageRequest";
		public static const SET_SELECTED_PAGE 	  : String = "setSelectedPage";
		
		//object
		public static const SELECTED_OBJECT_CHANGED : String = "selectedObjectChanged";
		
		public static const CHANGE_SELECTED_OBJECT_REQUEST  : String = "changeSelectedObjectRequest";
		public static const SET_SELECTED_OBJECT 			: String = "setSelectedObject";
		
		public function StatesProxy()
		{
			super( NAME );
		}
		
		override public function onRegister() : void
		{
			isSelectedApplicationChanged = false;
			isSelectedPageChanged = false;
			isSelectedObjectChanged = false;
		}
		
		public override function set selectedApplication( value : ApplicationVO ) : void
		{
			super.selectedApplication =  value;
			
			data[ SELECTED_PAGE ] = null;
		}
		
		public override function set selectedPage( value : PageVO ) : void
		{
			if ( value && value.typeVO.id != "753ea72c-475d-4a29-96be-71c522ca2097" )
				return;
			
			if ( data[ SELECTED_PAGE ] == value )
				return;
			
			if ( data[ SELECTED_PAGE ] && value && data[ SELECTED_PAGE ].id == value.id )
				return;
			
			data[ SELECTED_PAGE ] = value;
			data[ SELECTED_OBJECT ] = null;
			
			isSelectedPageChanged = true;
			
			sendNotifications();
		}
		
		public override function set selectedObject( value : ObjectVO ) : void
		{
			if ( value && value.pageVO.typeVO.id != "753ea72c-475d-4a29-96be-71c522ca2097" )
				return;
			
			if ( data[ SELECTED_OBJECT ] == value )
				return;
			
			if ( data[ SELECTED_OBJECT ] && value && data[ SELECTED_OBJECT ].id == value.id )
				return;
			
			data[ SELECTED_OBJECT ] = value;
			isSelectedObjectChanged = true;
			
			sendNotifications();
		}
		
		public override function setStates( states : Object ) : void
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
			
			sendNotifications();
		}
		
		override public function onRemove() : void
		{
			data = null;
		}
		
	}
}