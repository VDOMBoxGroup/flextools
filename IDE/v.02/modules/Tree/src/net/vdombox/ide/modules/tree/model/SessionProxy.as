package net.vdombox.ide.modules.tree.model
{
	import net.vdombox.ide.common.model.SessionProxy;
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.vo.TreeElementVO;
	import net.vdombox.ide.modules.tree.model.vo.TreeLevelVO;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class SessionProxy extends net.vdombox.ide.common.model.SessionProxy
	{
		public static const NAME : String = "SessionProxy";

		public static const SELECTED_APPLICATION : String = "selectedApplication";
		public static const SELECTED_PAGE : String = "selectedPage";
		//public static const SELECTED_OBJECT : String = "selectedObject";
		public static const SELECTED_TREE_ELEMENT : String = "selectedTreeElement";
		public static const SELECTED_TREE_LEVEL : String = "selectedTreeLevel";
		
		
		public static const SELECTED_APPLICATION_CHANGED : String = "selectedApplicationChanged";
		
		public static const SELECTED_PAGE_CHANGED : String = "selectedPageChanged";
		public static const SET_SELECTED_PAGE 	  : String = "setSelectedPage";
		
		public static const SELECTED_OBJECT_CHANGED : String = "selectedObjectChanged";
		
		
		public static const SELECTED_TREE_ELEMENT_CHANGE_REQUEST : String = "selectedTreeElementChangeRequest";
		public static const SELECTED_TREE_ELEMENT_CHANGED : String = "selectedTreeElementChanged";
		
		public static const SELECTED_TREE_LEVEL_CHANGE_REQUEST : String = "selectedTreeLevelChangeRequest";
		public static const SELECTED_TREE_LEVEL_CHANGED : String = "selectedTreeLevelChanged";

		public function SessionProxy()
		{
			super();
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

		public function get selectedTreeElement() : TreeElementVO
		{
			return data[ SELECTED_TREE_ELEMENT ];
		}
		
		public function set selectedTreeElement( value : TreeElementVO ) : void
		{
			if ( data[ SELECTED_TREE_ELEMENT ] == value )
				return;
			
			if ( data[ SELECTED_TREE_ELEMENT ] && value && data[ SELECTED_TREE_ELEMENT ].id == value.id )
				return;
			
			data[ SELECTED_TREE_ELEMENT ] = value;
			
			sendNotification( SELECTED_TREE_ELEMENT_CHANGED, data[ SELECTED_TREE_ELEMENT ] );
		}
		
		public function get selectedTreeLevel() : TreeLevelVO
		{
			return data[ SELECTED_TREE_LEVEL ];
		}
		
		public function set selectedTreeLevel( value : TreeLevelVO ) : void
		{
			if ( data[ SELECTED_TREE_LEVEL ] == value )
				return;
			
			if ( data[ SELECTED_TREE_LEVEL ] && value && data[ SELECTED_TREE_LEVEL ].level == value.level )
				return;
			
			data[ SELECTED_TREE_LEVEL ] = value;
			
			sendNotification( SELECTED_TREE_LEVEL_CHANGED, data[ SELECTED_TREE_LEVEL ] );
		}
		
		private function sendNotifications() : void
		{
			if ( isSelectedApplicationChanged )
			{
				isSelectedApplicationChanged = false;
				sendNotification( SELECTED_APPLICATION_CHANGED, data[ SELECTED_APPLICATION ] );
			}

			if ( isSelectedPageChanged )
			{
				isSelectedPageChanged = false;
				
				if (selectedPage){
					var structureProxy : StructureProxy = facade.retrieveProxy( StructureProxy.NAME ) as StructureProxy;
					selectedTreeElement = structureProxy.getTreeElementByVO( selectedPage );
				}
							
				sendNotification( SELECTED_PAGE_CHANGED, data[ SELECTED_PAGE ] );

			}

			if ( isSelectedObjectChanged )
			{
				isSelectedObjectChanged = false;
				sendNotification( SELECTED_OBJECT_CHANGED, data[ SELECTED_OBJECT ] );
			}
		}
	}
}