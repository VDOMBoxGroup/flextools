/*
	Class ResourcesMediator is a wrapper over the Resourses.mxml.
*/
package net.vdombox.object_editor.view.mediators
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	import flash.net.dns.AAAARecord;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	import net.vdombox.object_editor.controller.AddResourceCommand;
	import net.vdombox.object_editor.controller.UpdateResourceCommand;
	import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
	import net.vdombox.object_editor.model.proxy.componentsProxy.ResourcesProxy;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.model.vo.ResourceVO;
	import net.vdombox.object_editor.view.essence.Resourses;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;


	/**
	 *
	 * @author adelfos
	 */
	public class ResourcesMediator extends Mediator implements IMediator
	{
		/**
		 *
		 * @default
		 */
		public static const NAME:String = "ResoursesMediator";

		/**
		 *
		 * @default
		 */
		public static const ADD_RESOURCE			:String = "addResource";
//		public static const DELETE_RESOURCE			:String = "deleteResource";
		/**
		 *
		 * @default
		 */
		public static const UPDATE_RESOURCE			:String = "updateResource";
		/**
		 *
		 * @default
		 */
		public static const RESOURCE_UPLOADED		:String = "resourceUploaded";

		private var objectTypeVO:ObjectTypeVO;

		/**
		 *
		 * @param viewComponent
		 * @param objTypeVO
		 */
		public function ResourcesMediator( viewComponent:Object, objTypeVO:ObjectTypeVO ) 
		{			
			super( NAME+objTypeVO.id, viewComponent );
			this.objectTypeVO = objTypeVO;	
			view.addEventListener( FlexEvent.SHOW, show );			

			facade.registerCommand(ADD_RESOURCE, 	AddResourceCommand);
			facade.registerCommand(UPDATE_RESOURCE, UpdateResourceCommand);
		}

		private function show(event: FlexEvent): void
		{	
			view.removeEventListener( FlexEvent.SHOW, show );

			view.addResourceButt.addEventListener	( MouseEvent.CLICK, addResource );
			view.deleteButton.addEventListener		( MouseEvent.CLICK, deleteResource );
			view.changeContentButt.addEventListener	( MouseEvent.CLICK, changeContent );
			view.exportContentButt.addEventListener	( MouseEvent.CLICK, exportContent );
			view.resourcesDataGrid.addEventListener	( Event.CHANGE, addStar );

			view.resourcesDataGrid.dataProvider = objectTypeVO.resources;
			view.validateNow();
		}


		private function addResource(event:MouseEvent):void
		{
			facade.sendNotification(ADD_RESOURCE);
		}

		private function exportContent(event:MouseEvent):void
		{
			var resVO: ResourceVO = view.resourcesDataGrid.selectedItem as ResourceVO;

			resourcesProxy.exportToFile(resVO) 
		}

		private function changeContent(event:MouseEvent):void
		{
			var resVO: ResourceVO = view.resourcesDataGrid.selectedItem as ResourceVO;

			facade.sendNotification(UPDATE_RESOURCE, resVO.id);
		}

		private function deleteResource(event:MouseEvent):void
		{
			var resVO: ResourceVO = view.resourcesDataGrid.selectedItem as ResourceVO;
			var resourcesVO : ArrayCollection = objectTypeVO.resources; 

			Alert.show("Do You want to delete ?","Delete",3, null, deleteResourceOk);

			function deleteResourceOk(event:CloseEvent):void
			{
				var selectedIndex:int  = view.resourcesDataGrid.selectedIndex;

				if (event.detail == Alert.YES)
				{
					var indexResVO  : int =  resourcesVO.getItemIndex(resVO)
					resourcesVO.removeItemAt(indexResVO)
					resourcesProxy.deleteFile(resVO);
					addStar();
				}

				// select a last resourse
				if (resourcesVO.length)
				{
					if (selectedIndex == resourcesVO.length )
						view.resourcesDataGrid.selectedIndex = selectedIndex - 1;
					else
						view.resourcesDataGrid.selectedIndex = selectedIndex;
				}
			}
		}

		private function get  resourcesProxy():ResourcesProxy
		{
			return facade.retrieveProxy(ResourcesProxy.NAME) as ResourcesProxy;
		}

		override public function listNotificationInterests():Array 
		{			
			return [ RESOURCE_UPLOADED, Resourses.RESOURCES_CHANGED, ObjectViewMediator.OBJECT_TYPE_VIEW_SAVED ];
		}

		override public function handleNotification( note:INotification ):void 
		{
			switch ( note.getName() ) 
			{				
				case RESOURCE_UPLOADED:
					var resVO: ResourceVO = note.getBody() as ResourceVO;
					objectTypeVO.resources.addItem(resVO);
					addStar();
					break;	
				
				case Resourses.RESOURCES_CHANGED:
				{
					addStar();
					break;
				}
					
				case ObjectViewMediator.OBJECT_TYPE_VIEW_SAVED:
				{
					if (objectTypeVO == note.getBody() )
						view.label= "Resources";
					break;
				}
			}
		}

		protected function addStar(event:Event=null):void
		{
			view.label= "Resourses*";			
			facade.sendNotification( ObjectViewMediator.OBJECT_TYPE_CHAGED, objectTypeVO);
		}
		
		/**
		 *
		 * @return
		 */
		protected function get view():Resourses
		{
			return viewComponent as Resourses;
		}
	}
}

