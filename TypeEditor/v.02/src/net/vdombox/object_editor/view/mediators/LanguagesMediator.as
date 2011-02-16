/*
	Class LanguagesMediator is a wrapper over the Languages.mxml
*/
package net.vdombox.object_editor.view.mediators
{	
	import flash.events.MouseEvent;
	
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.essence.Languages;
	import net.vdombox.object_editor.view.popups.NewLanguage;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class LanguagesMediator extends Mediator implements IMediator
	{
		public static const NAME:String 		= "LanguagesMediator";
		public static const ADD_LANGUAGE:String = "addLaguage";
		private var objectTypeVO:ObjectTypeVO;
		
		public function LanguagesMediator( viewComponent:Object, objTypeVO:ObjectTypeVO ) 
		{			
			super( NAME+objTypeVO.id, viewComponent );
			this.objectTypeVO = objTypeVO;	
			view.addEventListener( FlexEvent.SHOW, showLanguages );			
		}
		
		private function showLanguages(event: FlexEvent): void
		{			
			view.languagesDataGrid.dataProvider = objectTypeVO.languages.words;
			addWordsToDataGrid();
			view.addLaguage.addEventListener( MouseEvent.CLICK,   addLaguage );
			view.addWord.addEventListener	( MouseEvent.CLICK,   addWord );
			view.deleteWord.addEventListener( MouseEvent.CLICK,   deleteWord );
			view.validateNow();
		}
		
		private function addWordsToDataGrid(): void
		{
			//new columns array
			var cols:Array = [];
			var col0:DataGridColumn =  view.languagesDataGrid.columns[0];
			
			//put in cols[0] column with "ID" 
			for each (var dc:DataGridColumn in view.languagesDataGrid.columns)
			{
				if (dc.dataField == "ID")
				{
					cols[0] = dc;
					break;
				}
			}
					
			//put the remaining elements 
			cols[1] = col0;
			var k:int = 2;
			for(var j:int = 1; j < view.languagesDataGrid.columnCount; j++)
			{
				if (view.languagesDataGrid.columns[j].dataField != "ID")
				{
					cols[k] = view.languagesDataGrid.columns[j];
					k++;
				}
			}
			
			cols[0].width = 50;
			view.languagesDataGrid.columns = cols;
		}
		
		//not used
		private function addWord(event:MouseEvent): void
		{
			var num:int = objectTypeVO.languages.words.length;
			objectTypeVO.languages.words.addItem({"ID":num, "en_US":"New word"});
			view.languagesDataGrid.selectedIndex = objectTypeVO.languages.words.length - 1;
			view.languagesDataGrid.validateNow();
			view.languagesDataGrid.scrollToIndex(view.languagesDataGrid.selectedIndex);
		}
			
		//not used
		private function deleteWord(event:MouseEvent): void
		{
			addStar();
			var obj:Object = [];
			obj["ID"] = view.languagesDataGrid.selectedItem.ID;
			objectTypeVO.languages.words.removeItemAt(objectTypeVO.languages.words.getItemIndex(view.languagesDataGrid.selectedItem));
		}
				
		private function addLaguage(event:MouseEvent): void
		{
			addStar();
			var popup:NewLanguage = NewLanguage(PopUpManager.createPopUp(view, NewLanguage, true));
			popup.addEventListener(CloseEvent.CLOSE, closeHandler);
			
			function closeHandler(event:CloseEvent):void
			{
				var lanName:String = event.target.languageName;
				
				if (lanName == "")
					return;
				
				var cols:Array = view.languagesDataGrid.columns;
				var dataGridColumn: DataGridColumn = new DataGridColumn(lanName);
				
				cols.push(dataGridColumn);
				view.languagesDataGrid.columns = cols;

				objectTypeVO.languages.locales.addItem({label:lanName, data:lanName});
				for (var i:String in objectTypeVO.languages.words)
				{
					var word:Object = objectTypeVO.languages.words[i];
					word[lanName] = word["en_US"];
				}
			}
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
				{
					if (objectTypeVO == note.getBody() )
						view.label= "Languages";
					break;
				}				
			}
		}
		
		protected function addStar():void
		{
			view.label= "Languages*";			
			facade.sendNotification( ObjectViewMediator.OBJECT_TYPE_CHAGED, objectTypeVO);
		}
		
		protected function get view():Languages
		{
			return viewComponent as Languages;
		}
	}
}