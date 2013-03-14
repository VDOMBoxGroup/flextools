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
	import net.vdombox.object_editor.view.essence.Information;
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
		public static const UPDATE_ICON			:String = "updateIcon";
		/**
		 *
		 * @default
		 */
		public static const RESOURCE_UPLOADED		:String = "resourceUploaded";
		
		public static const RESOURCE_CHANGED		:String	= "resourceChanged";	

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
			facade.registerCommand(UPDATE_ICON, UpdateResourceCommand);
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
			return [ RESOURCE_UPLOADED, Resourses.RESOURCES_CHANGED, ObjectViewMediator.OBJECT_TYPE_VIEW_SAVED, RESOURCE_CHANGED ];
		}

		override public function handleNotification( note:INotification ):void 
		{
			var body : Object = note.getBody();
			
			switch ( note.getName() ) 
			{				
				case RESOURCE_UPLOADED:
				{
					var resVO: ResourceVO = body as ResourceVO;
					objectTypeVO.resources.addItem(resVO);
					addStar();
					break;	
				}
					
				case RESOURCE_CHANGED:
				{
					resVO = body.resourceVO as ResourceVO;
					var oldID : String = body.oldID as String;
					var oldResourse : String = resourcesProxy.geIconByID( oldID );
					var newResourse : String = resourcesProxy.geIconByID( resVO.id );
					
					if ( objectTypeVO.icon == oldResourse )
						objectTypeVO.icon = newResourse;
					else if ( objectTypeVO.structureIcon == oldResourse )
						objectTypeVO.structureIcon = newResourse;
					else if ( objectTypeVO.editorIcon == oldResourse )
						objectTypeVO.editorIcon = newResourse;
					
					var resources : ArrayCollection = objectTypeVO.resources;
					
					for ( var i : int = 0; i < resources.length; i++ )
					{
						if ( resources[i].id == oldID )
						{
							objectTypeVO.resources.removeItemAt(i);
							objectTypeVO.resources.addItemAt(resVO, i);
						}
					}
						
					addStar();
					
					facade.sendNotification(Information.INFORMATION_CHANGED);
					facade.sendNotification(Resourses.RESOURCES_CHANGED);	
					break;	
				}
				
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

