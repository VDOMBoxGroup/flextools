package net.vdombox.object_editor.view.mediators
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
	import net.vdombox.object_editor.model.vo.AttributeVO;
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
			//aaaaa повторяется при каждом нажатии на tab
			view.addLaguage.addEventListener( MouseEvent.CLICK,   addLaguage );
			view.addWord.addEventListener	( MouseEvent.CLICK,   addWord );
			view.deleteWord.addEventListener( MouseEvent.CLICK,   deleteWord );
			view.validateNow();
		}
		
		private function addWord(event:MouseEvent): void
		{
			var num:int = Math.round(Math.random()*1000);
			objectTypeVO.languages.words.addItem({"ID":num, "en_US":"New word"});
			view.languagesDataGrid.selectedIndex = objectTypeVO.languages.words.length - 1;
			view.languagesDataGrid.validateNow();
			view.languagesDataGrid.scrollToIndex(view.languagesDataGrid.selectedIndex);
		}
		
		private function deleteWord(event:MouseEvent): void
		{
			var obj:Object = [];
			obj["ID"] = view.languagesDataGrid.selectedItem.ID;
			objectTypeVO.languages.words.removeItemAt(objectTypeVO.languages.words.getItemIndex(view.languagesDataGrid.selectedItem));
		}
				
		private function addLaguage(event:MouseEvent): void
		{
			var popup:NewLanguage = NewLanguage(PopUpManager.createPopUp(view, NewLanguage, true));
			popup.addEventListener(CloseEvent.CLOSE, closeHandler);
			
			function closeHandler(event:CloseEvent):void
			{
				var lanName:String = event.target.languageName;
				
				if(lanName == "")return;
				
				var cols:Array = view.languagesDataGrid.columns;
				var dataGridColumn: DataGridColumn = new DataGridColumn(lanName);
				
				cols.push(dataGridColumn);
				view.languagesDataGrid.columns = cols;
				
//				for (var i:String in objectTypeVO.languages.words)
//				{
//					var word:Object = arLanguages[i];
//					word[lan] = word["en_US"];
//				}
			}
		}
		
		
		protected function get view():Languages
		{
			return viewComponent as Languages;
		}
	}
}