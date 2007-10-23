package vdom {
	
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import vdom.connection.protect.Code;
import flash.net.sendToURL;
import flash.utils.getTimer;
import mx.core.Application;
	
public class Languages implements IEventDispatcher {
	
	private static var instance:Languages;
	
	private var dispatcher:EventDispatcher;
	private var _defaultLanguage:XMLList;
	private var _defaultLanguageCode:String;
	private var _currentLanguage:XMLList;
	private var _currentLanguageCode:String;
	private var allLanguages:XMLList;
	private var allLanguageCode:XMLList;
	
	public static function getInstance():Languages
	{
		if (!instance) {
			
			instance = new Languages();
		}

		return instance;
	}
	
	public function Languages() {
		
		if (instance)
			throw new Error("Instance already exists.");
	}
	
	public function init(languages:XML, aviableLanguages:XML, defaultLanguageCode:String):void {
	
		dispatcher = new EventDispatcher(this);
		allLanguageCode = aviableLanguages.*;
		allLanguages = languages.Language;
		_defaultLanguageCode = defaultLanguageCode;
		_defaultLanguage = allLanguages.(@Code == _defaultLanguageCode).*;
		_currentLanguage = _defaultLanguage;
	}
	
	[Bindable (event='languageChanged')]
	public function get language():XMLList {
		
		//trace('languageChangedGet');
		return _currentLanguage;
	}
	
	public function set language(language:XMLList):void {
		//trace('languageChangedSet');
	}
	
	public function parseLanguageData(languageData:XML):void {
		
		//var beginT:int = getTimer();
		for each(var element:XML in languageData.Type.Languages.Language.Sentence) {
			
			var languageCode:String = element.parent().@Code;
			
			if(allLanguageCode.(@Code == languageCode)[0] == undefined) break;
			
			var lng:XML = allLanguages.(@Code == languageCode)[0];
			
			var idString:String = element.parent().parent().parent().Information.ID.toString() + '-' + element.@ID.toString();

			lng.appendChild(<Sentence ID={idString} label="">{element.toString()}</Sentence>);
		}
		
		_defaultLanguage = allLanguages.(@Code == _defaultLanguageCode).*;
		changeLanguage(_currentLanguageCode);
		//trace((getTimer()-beginT)/1000);
	}
	
	public function changeLanguage(languageLabel:String):void {
		
		var newLanguage:XMLList = allLanguages.(@Code == languageLabel);
		var tmpLanguage:XMLList = _defaultLanguage.copy();
		
		for each(var sentence:XML in newLanguage.*) {
			
			tmpLanguage.(@ID == sentence.@ID)[0] = sentence.toString();
		}

		_currentLanguage = tmpLanguage;
		_currentLanguageCode = languageLabel;
		Application.application.executeChildBindings(true);
	}
	
	
	public function addEventListener(type:String, listener:Function, 
		useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
	
		dispatcher.addEventListener(type, listener, useCapture, priority);
	}
	   
	public function dispatchEvent(evt:Event):Boolean {
	
		return dispatcher.dispatchEvent(evt);
	}
	
	public function hasEventListener(type:String):Boolean {
	
		return dispatcher.hasEventListener(type);
	}
	
	public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
	
		dispatcher.removeEventListener(type, listener, useCapture);
	}
	   
	public function willTrigger(type:String):Boolean {
	
		return dispatcher.willTrigger(type);
	}
}
}