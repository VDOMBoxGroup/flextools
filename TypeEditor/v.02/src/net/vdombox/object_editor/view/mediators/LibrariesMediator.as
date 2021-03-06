/*
	Class LibrariesMediator is a wrapper over the Libraries.mxml
*/
package net.vdombox.object_editor.view.mediators
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	
	import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
	import net.vdombox.object_editor.model.vo.LibraryVO;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.essence.Libraries;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class LibrariesMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "LibrariesMediator";
		private var objectTypeVO:ObjectTypeVO;
		private var currentLibraryVO: LibraryVO;
		
		public function LibrariesMediator( viewComponent:Object, objTypeVO:ObjectTypeVO ) 
		{			
			super( NAME+objTypeVO.id, viewComponent );
			this.objectTypeVO = objTypeVO;	
			view.addEventListener( FlexEvent.SHOW, showLibraries );
		}
		
		private function showLibraries(event: FlexEvent): void
		{		
			view.removeEventListener				 ( FlexEvent.SHOW, 	showLibraries );
			view.librariesList.addEventListener		 ( Event.CHANGE, 	selectLibrary );
			view.code.addEventListener  			 ( Event.CHANGE, 	changeCode );
			view.target.addEventListener			 ( Event.CHANGE, 	changeTarget );
			view.addLibraryButton.addEventListener   ( MouseEvent.CLICK, addLibrary );
			view.deleteLibraryButton.addEventListener( MouseEvent.CLICK, deleteLibrary );
			compliteLibraries();
			setCurrentLibrarie();
		}
		
		protected function compliteLibraries( ):void
		{	
			view.librariesList.dataProvider = objectTypeVO.libraries;
		}
		
		private function setCurrentLibrarie(listIndex:int = 0):void
		{
			if (listIndex < 0)
				listIndex = 0;
			
			if (objectTypeVO.libraries.length > 0)
			{				
				currentLibraryVO = objectTypeVO.libraries[listIndex].data;
				fillArea(currentLibraryVO);
				view.currentLibrary = {label:"Library", data:currentLibraryVO};
				view.librariesList.selectedIndex = listIndex;
				view.validateNow();
			}
			else
			{
				view.clearLibraryFields();
				view.currentLibrary	= null;
				view.target.text	= "";
				view.code.text		= null;
				currentLibraryVO	= null;
			}
		}
		
		private function changeCode( event:Event ):void
		{ 
//			view.currentItem.label = event.target.text;
			addStar();
			if (currentLibraryVO)
				currentLibraryVO.text	= view.code.text;
		}
		
		private function changeTarget( event:Event ):void
		{ 
			addStar();
			if (currentLibraryVO)
			{				
				currentLibraryVO.target	= view.target.text;
				view.currentLibrary.label  = view.target.text;
				view.librariesList.dataProvider.itemUpdated(view.currentLibrary);
				view.librariesList.selectedItem = view.currentLibrary;
				view.librariesList.ensureIndexIsVisible(view.librariesList.selectedIndex);
			}
		}
		
		public function validateObjectTypeVO(event:Event):void
		{
			addStar();
			if (currentLibraryVO)
				currentLibraryVO.text = view.code.text;
		}
		
		private function selectLibrary(event:Event):void
		{ 
			currentLibraryVO = view.librariesList.selectedItem.data as LibraryVO;
			fillArea(currentLibraryVO);
		}
				
		private function fillArea(libVO:LibraryVO):void
		{
			view.code.text	  = libVO.text;	
			view.target.text  = libVO.target;
		}
		
		private function addLibrary(event:MouseEvent): void
		{	
			addStar();
			currentLibraryVO = new LibraryVO();
			objectTypeVO.libraries.addItem( {label:"Library", data:currentLibraryVO} );
			fillArea(currentLibraryVO);			
			view.currentLibrary = {label:"Library", data:currentLibraryVO};
			
			view.librariesList.selectedIndex = view.librariesList.dataProvider.length-1;
			view.librariesList.validateNow();
			//			view.attributesList.scrollToIndex(view.languagesDataGrid.selectedIndex);
		}
		
		private function deleteLibrary(event:MouseEvent): void
		{
			addStar();
			var selectInd:int = view.librariesList.selectedIndex;
			objectTypeVO.libraries.removeItemAt(selectInd);
			setCurrentLibrarie(selectInd - 1);			
		}
		
		private function getCurrentItem(nameLib:String):Object
		{			
			for each (var lib:Object in objectTypeVO.libraries)
			{
				if (lib["label"] == nameLib)
				{
					return lib;
					break;
				}
			}
			return new Object();
		}
		
		override public function listNotificationInterests():Array 
		{			
			return [ ObjectViewMediator.OBJECT_TYPE_VIEW_SAVED ];
		}
		
		override public function handleNotification( note:INotification ):void 
		{
			switch ( note.getName() ) 
			{				
				case ObjectViewMediator.OBJECT_TYPE_VIEW_SAVED:
					if (objectTypeVO == note.getBody())
						view.label= "Libraries";
					break;	
			}
		}
		
		protected function addStar():void
		{
			view.label= "Libraries*";			
			facade.sendNotification( ObjectViewMediator.OBJECT_TYPE_CHAGED, objectTypeVO);
		}
				
		protected function get view():Libraries
		{
			return viewComponent as Libraries;
		}
	}
}