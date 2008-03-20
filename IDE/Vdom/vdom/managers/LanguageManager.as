package vdom.managers {
	
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import mx.resources.IResourceManager;
import mx.resources.ResourceBundle;
import mx.resources.ResourceManager;
	

public class LanguageManager implements IEventDispatcher {
	
	private static var instance:LanguageManager;
	
	private var resourceManager:IResourceManager;
	private var dispatcher:EventDispatcher;
	
	private var _languageList:XMLList;
	
	private var allLocales:Array;
	private var defaultLocale:String;
	private var _currentLocale:String;

	public static function getInstance():LanguageManager
	{
		if (!instance) {
			
			instance = new LanguageManager();
		}

		return instance;
	}
	
	public function LanguageManager() {
		
		if (instance)
			throw new Error("Instance already exists.");
		
		resourceManager = ResourceManager.getInstance();
		dispatcher = new EventDispatcher();
	}
	
	public function init(languageList:XML):void {
		
		_languageList = languageList.*;
		
		allLocales = [];
		
		for each(var code:XML in languageList.*) 
			allLocales.push(code.@code.toString());
		
		_currentLocale = defaultLocale = allLocales[0];
		
		resourceManager.localeChain = [defaultLocale];
	}
	
	public function get languageList():XMLList {
		
		return _languageList;
	}
	
	public function get currentLocale():String {
		
		return _currentLocale;
	}
	
	public function changeLocale(locale:String):void {
		
		if(_currentLocale != locale && allLocales.indexOf(locale) != -1) {
			
			resourceManager.localeChain = [locale, defaultLocale]
			_currentLocale = locale;
		}
			
	}
	
	public function parseLanguageData(languageData:XMLList):void {
		
		//var beginT:int = getTimer();
		var resourceBundles:Object = {}; 
		
		var localeIndex:Number = -1;
		var languageCode:String = ''
		var currentBundle:ResourceBundle;
		
		var typeName:String = '';
		var resourceName:String = '';
		var content:String = '';
		for each(var sentence:XML in languageData.Languages.Language.Sentence) {
			
			languageCode = sentence.parent().@Code;
			localeIndex = allLocales.indexOf(languageCode);
			
			if(localeIndex == -1) break;
			
			typeName = sentence.parent().parent().parent().Information.Name.toString();
			
			if(!resourceBundles[languageCode])
				resourceBundles[languageCode] = [];
			
			if(!resourceBundles[languageCode][typeName])
				resourceBundles[languageCode][typeName] = new ResourceBundle(languageCode, typeName);
					 
			currentBundle = resourceBundles[languageCode][typeName];
			
			resourceName = sentence.@ID.toString();
			content = sentence.toString();
			
			currentBundle.content[resourceName] = content;
			
			resourceManager.addResourceBundle(currentBundle);
		}
		
		resourceManager.update();
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