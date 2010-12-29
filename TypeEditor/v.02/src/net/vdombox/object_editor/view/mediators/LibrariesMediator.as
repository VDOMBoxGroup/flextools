package net.vdombox.object_editor.view.mediators
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.Sort;
	import mx.collections.SortField;
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
		
		private function changeCode( event:Event ):void
		{ 
//			view.currentItem.label = event.target.text;
			view.label= "Libraries*";			
			facade.sendNotification( ObjectViewMediator.OBJECT_TYPE_CHAGED, objectTypeVO);
			if( currentLibraryVO )
			{				
				currentLibraryVO.text	= view.libCode.text;
			}
		}
		
		private function changeTarget( event:Event ):void
		{ 
			//			view.currentItem.label = event.target.text;
			view.label= "Libraries*";			
			facade.sendNotification( ObjectViewMediator.OBJECT_TYPE_CHAGED, objectTypeVO);
			if( currentLibraryVO )
			{				
				currentLibraryVO.target	= view.target.text;
				view.currentLibrary.label  = view.target.text;
				view.librariesList.dataProvider.itemUpdated(view.currentLibrary);
				sortLibraries();
				view.librariesList.selectedItem = view.currentLibrary;
				view.librariesList.ensureIndexIsVisible(view.librariesList.selectedIndex);
			}
		}
		
		public function validateObjectTypeVO(event:Event):void
		{
			view.label= "Libraries*";			
			facade.sendNotification( ObjectViewMediator.OBJECT_TYPE_CHAGED, objectTypeVO);
			if( currentLibraryVO )
			{				
				currentLibraryVO.text	= view.libCode.text;
			}
		}
		
		private function selectLibrary(event:Event):void
		{ 
			currentLibraryVO = view.librariesList.selectedItem.data as LibraryVO;
			fillArea(currentLibraryVO);
		}
				
		private function fillArea(libVO:LibraryVO):void
		{
			view.libCode.text = libVO.text;	
			view.target.text  = libVO.target;
		}
		
		private function showLibraries(event: FlexEvent): void
		{		
//			view.addEventListener( Event.CHANGE, validateObjectTypeVO );
			view.librariesList.addEventListener(Event.CHANGE, selectLibrary);
			view.libCode.addEventListener( Event.CHANGE, changeCode );
			view.target.addEventListener( Event.CHANGE, changeTarget );
			view.addLibraryButton.addEventListener   ( MouseEvent.CLICK, addLibrary );
			view.deleteLibraryButton.addEventListener( MouseEvent.CLICK, deleteLibrary );
			compliteLibraries();
			view.validateNow();
		}
		
		private function addLibrary(event:MouseEvent): void
		{			
			var libVO:LibraryVO= new LibraryVO( "newTarget"+ Math.round(Math.random()*100) );
			objectTypeVO.libraries.addItem( {label:libVO.target, data:libVO} );
			view.target.text = libVO.target;
			view.currentLibrary = getCurrentItem(libVO.target);
			currentLibraryVO = view.currentLibrary.data;
			view.librariesList.selectedItem = view.currentLibrary;
			view.librariesList.validateNow();
			//			view.attributesList.scrollToIndex(view.languagesDataGrid.selectedIndex);
		}
		
		private function getCurrentItem(nameLib:String):Object
		{			
			for each(var lib:Object in objectTypeVO.libraries )
			{
				if( lib["label"] == nameLib )
				{
					return lib;
					break;
				}
			}
			return new Object();
		}
		
		private function deleteLibrary(event:MouseEvent): void
		{
			var selectInd:uint = view.librariesList.selectedIndex;
			objectTypeVO.libraries.removeItemAt(selectInd);
		}
		
		private function sortLibraries():void 
		{
			objectTypeVO.libraries.sort = new Sort();
			objectTypeVO.libraries.sort.fields = [ new SortField( 'label' ) ];
			objectTypeVO.libraries.refresh();
		}
		
		protected function compliteLibraries( ):void
		{	
			sortLibraries();
			view.librariesList.dataProvider = objectTypeVO.libraries;
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
					if (objectTypeVO == note.getBody() )
						view.label= "Libraries";
					break;	
			}
		}	
		
		protected function get view():Libraries
		{
			return viewComponent as Libraries;
		}
	}
}