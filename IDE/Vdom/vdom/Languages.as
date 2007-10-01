package vdom {
	
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import mx.containers.ControlBar;
	
public class Languages implements IEventDispatcher {
	
	private static var instance:Languages;
	
	private var dispatcher:EventDispatcher;
	private var _defaultLanguage:XMLList;
	private var _currentLanguage:XMLList;
	private var allLanguages:XMLList;
	ControlBar
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
	
	public function init(languages:XML, defaultLanguage:String):void {
	
		dispatcher = new EventDispatcher(this);
		allLanguages = languages.language;
		
		_defaultLanguage = allLanguages.(@ID == defaultLanguage).*;
		_currentLanguage = _defaultLanguage;
	}
	
	[Bindable (event='languageChanged')]
	public function get language():XMLList {
		
		return _currentLanguage;
	}
	
	public function set language(language:XMLList):void {
		
	}
	
	public function changeLanguage(languageLabel:String):void {
		
		var newLanguage:XMLList = allLanguages.(@ID == languageLabel);
		var tmpLanguage:XMLList = _defaultLanguage.copy();
		
		for each(var sentence:XML in newLanguage.*) {
			
			tmpLanguage.(@ID == sentence.@ID)[0] = sentence.toString();
		}

		_currentLanguage = tmpLanguage;
		dispatchEvent(new Event('languageChanged'));
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